#--
# Copyright (c) 2015-2016, John Mettraux, jmettraux+flon@gmail.com
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
# Made in Japan.
#++

require 'zlib'


module Flor

  class Storage

    attr_reader :unit, :db, :models

    def initialize(unit)

      @unit = unit

      @models = {}
      @archive = @unit.conf['sto_archive']

      connect
    end

    def shutdown

      @db.disconnect
    end

    def migrate(to=nil, from=nil)

      dir = @unit.conf['db_migrations'] || 'migrations'

      Sequel::Migrator.apply(@db, dir, to, from)
    end

    def clear

      [
        :flon_messages, :flon_executions, :flon_timers, :flon_traps,
        :flon_traces
      ].each do |t|
        @db[t].delete
      end
    end

    def load_exids

      @db[:flon_messages]
        .select(:exid)
        .where(status: 'created')
        .order_by(:ctime)
        .distinct
        .all
        .collect { |r| r[:exid] }
    end

    def load_execution(exid)

      e = @db[:flon_executions]
        .select(:id, :content)
        .where(exid: exid) # status active or terminated doesn't matter
        .first

      ex =
        if e
          ex =
            from_blob(e[:content]) ||
            fail("couldn't parse execution (db id #{e[:id]})")
          ex['id'] =
            e[:id]
          ex
        else
          put_execution({
            'exid' => exid, 'nodes' => {}, 'errors' => [], 'ashes' => {},
            'counters' => {}, 'start' => Flor.tstamp
          })
        end

      ex
    end

    def put_execution(ex)

      if i = ex['id']

        status =
          if ex['nodes']['0']['removed']
            'terminated'
          else
            'active'
          end

        ex['end'] ||= Flor.tstamp \
          if status == 'terminated'
        ex['duration'] = Flor.to_time(ex['end']) - Flor.to_time(ex['start']) \
          if ex['end']

        @db[:flon_executions]
          .where(id: i)
          .update(
            content: to_blob(ex),
            status: status,
            mtime: Time.now)
      else

        ex['id'] =
          @db[:flon_executions]
            .insert(
              domain: Flor.domain(ex['exid']),
              exid: ex['exid'],
              content: to_blob(ex),
              status: 'active',
              ctime: Time.now,
              mtime: Time.now)
      end

      ex
    end

    def fetch_messages(exid)

      @db.transaction do

        ms = @db[:flon_messages]
          .select(:id, :content)
          .where(status: 'created', exid: exid)
          .order_by(:id)
          .map { |m| r = from_blob(m[:content]) || {}; r['mid'] = m[:id]; r }

        @db[:flon_messages]
          .where(id: ms.collect { |m| m['mid'] })
          .update(status: 'loaded')
             #
             # flag them as "loaded" so that other scheduler don't pick them

        ms
      end
    end

    def fetch_traps(exid)

      traps
        .where(status: 'active')
        .where(domain: split_domain(exid))
        .all
    end

    def consume(messages)

      if @archive
        @db[:flon_messages]
          .where(id: messages.collect { |m| m['mid'] }.compact)
          .update(status: 'consumed', mtime: Time.now)
      else
        @db[:flon_messages]
          .where(id: messages.collect { |m| m['mid'] }.compact)
          .delete
      end
    end

    def load_timers

      timers
        .select(:id, :content)
        .where(status: 'created')
        .order_by(:id)
    end

    def put_messages(ms)

      return if ms.empty?

      n = Time.now

      @db[:flon_messages]
        .import(
          [ :domain, :exid, :point, :content,
            :status, :ctime, :mtime ],
          ms.map { |m|
            [ Flor.domain(m['exid']), m['exid'], m['point'], to_blob(m),
              'created', n, n ]
          })

      @unit.notify(nil, ms.collect { |m| m['exid'] }.uniq)
    end

    def put_message(m)

      put_messages([ m ])
    end

    def put_timer(message)

      n = Time.now

      t, nt =
        if a = message['at']
          [ 'at', Rufus::Scheduler.parse(a) ]
        elsif i = message['in']
          [ 'in', n + Rufus::Scheduler.parse(i) ]
        elsif message['cron']
          [ 'cron', n + 365 * 24 * 3600 ] # FIXME
        else
          [ 'every', n + 365 * 24 * 3600 ] # FIXME
        end

      id = @db[:flon_timers].insert(
        domain: Flor.domain(message['exid']),
        exid: message['exid'],
        nid: message['nid'],
        type: t,
        schedule: message[t],
        ntime: nt,
        content: to_blob(message),
        status: 'active',
        ctime: n,
        mtime: n)

      @unit.notify(nil, @unit.timers[id])
    end

    def trigger_timer(timer)

      @db.transaction do

        if @archive
          @db[:flon_timers]
            .where(id: timer.id)
            .update(status: 'triggered')
        else
          @db[:flon_timers]
            .where(id: timer.id)
            .delete
        end

        put_message(timer.to_trigger_message)
      end
    end

    def remove_node(exid, n)

      removal =
        @archive ?
        lambda { |u| u.update(status: 'removed') } :
        lambda { |u| u.delete }

      @db.transaction do

        @db[:flon_timers]
          .where(exid: exid, nid: n['nid'])
          .tap { |u| removal.call(u) }
        @db[:flon_traps]
          .where(exid: exid, nid: n['nid'])
          .tap { |u| removal.call(u) }
      end
    end

    def put_trap(node, tra)

      @db.transaction do

        exid = node['exid']
        dom = Flor.domain(exid)

        id = @db[:flon_traps].insert(
          domain: dom,
          exid: exid,
          nid: tra['bnid'],
          onid: node['nid'],
          trange: tra['range'],
          tpoints: tra['points'],
          ttags: tra['tags'],
          theats: tra['heats'],
          theaps: tra['heaps'],
          content: to_blob(tra),
          status: 'active')

        traps[id]
      end
    end

    def trace(exid, nid, tracer, text)

      @db[:flon_traces].insert(
        domain: Flor.domain(exid),
        exid: exid,
        nid: nid,
        tracer: tracer,
        text: text,
        tstamp: Time.now)
    end

    protected

    def split_domain(exid)

      Flor.domain(exid)
        .split('.')
        .inject([]) { |a, elt| a << [ a.last, elt ].compact.join('.'); a }
    end

    class DbLogger

      def initialize(unit); @unit = unit; end

      def info(msg); @unit.logger.db_log(:info, msg); end
      def error(msg); @unit.logger.db_log(:error, msg); end
    end

    def connect

      uri = @unit.conf['sto_uri']

      #uri = "jdbc:#{uri}" \
      #  if RUBY_PLATFORM.match(/java/) && uri.match(/\Asqlite:/)

      @db = Sequel.connect(uri)

      @db_logger = DbLogger.new(@unit)
      @db.loggers << @db_logger
    end

    def self.to_blob(h)

      Sequel.blob(Zlib::Deflate.deflate(JSON.dump(h)))
    end

    def self.from_blob(content)

      JSON.parse(Zlib::Inflate.inflate(content))
    end

    def to_blob(h); self.class.to_blob(h); end
    def from_blob(content); self.class.from_blob(content); end
  end
end

