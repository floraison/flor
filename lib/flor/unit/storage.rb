#--
# Copyright (c) 2015-2017, John Mettraux, jmettraux+flor@gmail.com
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
      @mutex = @unit.conf['sto_sync'] ? Mutex.new : nil

      connect
    end

    def shutdown

      @db.disconnect
#p [ :disconnected, @db.object_id ]
    end

    def db_version

      (@db[:schema_info].first rescue {})[:version]
    end

    def migration_version

      Dir[File.join(File.dirname(__FILE__), '../migrations/*.rb')]
        .inject([]) { |a, fn|
          m = File.basename(fn).match(/^(\d{4})_/)
          a << m[1].to_i if m
          a
        }
        .max
    end

    def ready?

      db_version == migration_version
    end

    def synchronize(sync=true, &block)

      Thread.current[:sto_errored_items] = nil

      if @mutex && sync
        @mutex.synchronize(&block)
      else
        block.call
      end
    end

    def migrate(to=nil, from=nil)

      dir =
        @unit.conf['db_migrations'] ||
        File.absolute_path(
          File.join(
            File.dirname(__FILE__), '..', 'migrations'))

      synchronize do

        Sequel::Migrator.run(
          @db, dir,
          :target => to, :current => from)

        # defaults for the migration version table:
        #:table => :schema_info
        #:column => :version
      end
    end

    def delete_tables

      @db.tables.each { |t| @db[t].delete if t.to_s.match(/^flor_/) }
    end

    def load_exids

      @db[:flor_messages]
        .select(:exid)
        .where(status: 'created')
        .order_by(:ctime)
        .distinct
        .all
        .collect { |r| r[:exid] }

    rescue => err

      @unit.logger.warn("#{self.class}#load_exids", err, '(returning [])')

      []
    end

    def load_execution(exid)

      e = @db[:flor_executions]
        .select(:id, :content)
        .where(exid: exid) # status active or terminated doesn't matter
        .first

      if e
        ex = from_blob(e[:content])
        fail("couldn't parse execution (db id #{e[:id]})") unless ex
        ex['id'] = e[:id]
        ex['size'] = e[:content].length
        ex
      else
        put_execution({
          'exid' => exid, 'nodes' => {}, 'errors' => [], 'tasks' => {},
          #'ashes' => {},
          'counters' => {}, 'start' => Flor.tstamp,
          'size' => -1
        })
      end
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
        ex['duration'] = Time.parse(ex['end']) - Time.parse(ex['start']) \
          if ex['end']

        data = to_blob(ex)
        ex['size'] = data.length

        synchronize do

          @db.transaction do

            now = Flor.tstamp

            @db[:flor_executions]
              .where(id: i)
              .update(
                content: data,
                status: status,
                mtime: now)

            remove_nodes(ex, status, now)
            update_pointers(ex, status, now)
          end
        end
      else

        data = to_blob(ex)
        ex['size'] = data.length

        synchronize do

          @db.transaction do

            now = Flor.tstamp

            ex['id'] =
              @db[:flor_executions]
                .insert(
                  domain: Flor.domain(ex['exid']),
                  exid: ex['exid'],
                  content: data,
                  status: 'active',
                  ctime: now,
                  mtime: now)

            remove_nodes(ex, status, now)
            update_pointers(ex, status, now)
          end
        end
      end

      ex

    rescue => err
      Thread.current[:sto_errored_items] = [ ex ]
      raise err
    end

    def fetch_messages(exid)

      synchronize do
        @db.transaction do

          ms = @db[:flor_messages]
            .select(:id, :content)
            .where(status: 'created', exid: exid)
            .order_by(:id)
            .map { |m| r = from_blob(m[:content]) || {}; r['mid'] = m[:id]; r }

          @db[:flor_messages]
            .where(id: ms.collect { |m| m['mid'] })
            .update(status: 'loaded')
               #
               # flag them as "loaded" so that other scheduler don't pick them

          ms
        end
      end
    end

    def fetch_traps(exid)

      traps
        .where(status: 'active')
        .where(domain: split_domain(exid))
        .all

    rescue => err

      @unit.logger.warn("#{self.class}#fetch_traps()", err, '(returning [])')

      []
    end

    def consume(messages)

      synchronize do
        if @archive
          @db[:flor_messages]
            .where(id: messages.collect { |m| m['mid'] }.compact)
            .update(status: 'consumed', mtime: Flor.tstamp)
        else
          @db[:flor_messages]
            .where(id: messages.collect { |m| m['mid'] }.compact)
            .delete
        end
      end

    rescue => err
      Thread.current[:sto_errored_items] = messages
      raise err
    end

    def load_timers

      timers
        .select(:id, :content)
        .where(status: 'active')
        .order_by(:id)
        .all

    rescue => err

      @unit.logger.warn("#{self.class}#load_timers()", err, '(returning [])')

      []
    end

    def put_messages(ms, syn=true)

      return if ms.empty?

      n = Flor.tstamp

      synchronize(syn) do

        @db[:flor_messages]
          .import(
            [ :domain, :exid, :point, :content,
              :status, :ctime, :mtime ],
            ms.map { |m|
              [ Flor.domain(m['exid']), m['exid'], m['point'], to_blob(m),
                'created', n, n ]
            })
      end

      @unit.wake_up_executions(ms.collect { |m| m['exid'] }.uniq)

    rescue => err
      Thread.current[:sto_errored_items] = ms
      raise err
    end

    def put_message(m)

      put_messages([ m ])
    end

    def put_timer(message)

      type, string = determine_type_and_schedule(message)

      next_time = compute_next_time(type, string)

      now = Flor.tstamp

      id =
        synchronize do
          @db[:flor_timers].insert(
            domain: Flor.domain(message['exid']),
            exid: message['exid'],
            nid: message['nid'],
            type: type,
            schedule: string,
            ntime: next_time,
            content: to_blob(message),
            count: 0,
            status: 'active',
            ctime: now,
            mtime: now)
        end

      @unit.timers[id]

    rescue => err
      Thread.current[:sto_errored_items] = [ message ]
      raise err
    end

    # Returns the timer if it is rescheduling
    #
    def trigger_timer(timer)

      r = nil

      synchronize do
        @db.transaction do

# TODO: cron/every stop conditions maybe?

          if timer.type != 'at' && timer.type != 'in'

            @db[:flor_timers]
              .where(id: timer.id)
              .update(
                count: timer.count + 1,
                ntime: compute_next_time(timer.type, timer.schedule),
                mtime: Flor.tstamp)
            r = timers[timer.id]

          elsif @archive

            @db[:flor_timers]
              .where(id: timer.id)
              .update(
                count: timer.count + 1,
                status: 'triggered',
                mtime: Flor.tstamp)

          else

            @db[:flor_timers]
              .where(id: timer.id)
              .delete
          end

          put_messages([ timer.to_trigger_message ], false)
        end
      end

      r

    rescue => err
      Thread.current[:sto_errored_items] = [ timer ]
      raise err
    end

    def put_trap(node, tra)

      exid = node['exid']
      dom = Flor.domain(exid)
      now = Flor.tstamp

      id =
        synchronize do
          @db.transaction do

            @db[:flor_traps].insert(
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
              status: 'active',
              ctime: now,
              mtime: now)
          end
        end

      traps[id]

    rescue => err
      Thread.current[:sto_errored_items] = [ node, tra ]
      raise err
    end

    def trace(exid, nid, tracer, text)

      text = text.is_a?(String) ? text : JSON.dump(text)

      synchronize do

        @db[:flor_traces].insert(
          domain: Flor.domain(exid),
          exid: exid,
          nid: nid,
          tracer: tracer,
          text: text,
          ctime: Flor.tstamp)
      end
    end

    def put_task_pointer(msg, tname, tconf)

      exid = msg['exid']
      dom = Flor.domain(exid)

      synchronize do

        @db[:flor_pointers]
          .insert(
            domain: dom,
            exid: exid,
            nid: msg['nid'],
            type: 'tasker',
            name: tname,
            ctime: Flor.tstamp)
      end
    end

    protected

    def remove_nodes(exe, status, now)

      exid = exe['exid']

      x = status == 'terminated' ? {} : { nid: exe['nodes'].keys }
        # if 'terminated' include all nodes

      if @archive
        @db[:flor_timers].where(exid: exid).exclude(x).update(status: 'removed')
        @db[:flor_traps].where(exid: exid).exclude(x).update(status: 'removed')
      else
        @db[:flor_timers].where(exid: exid).exclude(x).delete
        @db[:flor_traps].where(exid: exid).exclude(x).delete
      end

      #@db[:flor_pointers].where(exid: exid).exclude(x).delete
        # done in update_pointers
    end

    def update_pointers(exe, status, now)

      exid = exe['exid']

      if status == 'terminated'
        @db[:flor_pointers].where(exid: exid).delete
        return
      end

      @db[:flor_pointers]
        .where(exid: exid)
        .where(Sequel.|({ type: %w[ var ] }, Sequel.~(nid: exe['nodes'].keys)))
        .delete
          #
          # Delete all pointer to vars, their value might have changed,
          # let's reinsert them.
          # Delete pointers to gone nodes.

      dom = Flor.domain(exid)

      pointers =
        exe['nodes'].inject([]) { |a, (nid, node)|
          ts = node['tags']
          ts.each { |t| a << [ dom, exid, nid, 'tag', t, nil, now ] } if ts
          a
        }

      pointers +=
        (exe['nodes']['0'] || { 'vars' => {} })['vars'].collect { |k, v|
          case v; when Integer, String, TrueClass, FalseClass
            [ dom, exid, '0', 'var', k, v.to_s, now ]
          when NilClass
            [ dom, exid, '0', 'var', k, nil, now ]
          else
            nil
          end
        }.compact

      pointers +=
        exe['tasks'].collect { |nid, v|
          [ dom, exid, nid, 'tasker', v['tasker'], v['name'], now ]
        }

      cps = @db[:flor_pointers] # current pointers
        .where(exid: exid)
        .select(:nid, :type, :name)
        .all
      pointers.reject! { |_, _, ni, ty, na, _, _|
        cps.find { |cp| cp[:nid] == ni && cp[:type] == ty && cp[:name] == na } }
          #
          # don't insert when already inserted

      @db[:flor_pointers]
        .import(
          [ :domain, :exid, :nid, :type, :name, :value, :ctime ],
          pointers)
    end

    def determine_type_and_schedule(message)

      t, s = message['type'], message['string']
      return [ t, s ] if t

      t = Fugit.determine_type(s)
      return [ t, s ] if t

      s = "every #{s}"
      return [ 'cron', s ] if Fugit.parse_nat(s)

      nil
    end

    def compute_next_time(type, string)

      f =
        case type
          when 'cron' then Fugit.parse_cron(string) || Fugit.parse_nat(string)
          when 'at' then Fugit.parse_at(string)
          when 'in' then Fugit.parse_duration(string)
          #when 'every' then Fugit.parse_duration(string)
          else Fugit.parse(string)
        end

      nt = f.is_a?(Time) ? f : f.next_time(Time.now) # local...

      Flor.tstamp(nt.utc)
    end

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

      #uri = DB.uri if uri == 'DB' && defined?(DB)
      uri = (Kernel.const_get(uri).uri rescue uri) if uri.match(/\A[A-Z]+\z/)
        # for cases where `sto_uri: "DB"`

      @db = Sequel.connect(uri)

      class << @db; attr_accessor :flor_unit; end
      @db.flor_unit = @unit

      if cv = @unit.conf['sto_connection_validation']

        to = cv.is_a?(Numeric) || cv.is_a?(String) ? cv.to_i : -1

        @db.extension(:connection_validator)
        @db.pool.connection_validation_timeout = to
          # NB: -1 means "check all the time"
      end

      @db_logger = DbLogger.new(@unit)
      @db.loggers << @db_logger
    end

    def self.to_blob(h)

      Sequel.blob(Zlib::Deflate.deflate(JSON.dump(h)))
#rescue => e; pp h; raise e
    end

    def self.from_blob(content)

      JSON.parse(Zlib::Inflate.inflate(content))
    end

    def to_blob(h); self.class.to_blob(h); end
    def from_blob(content); self.class.from_blob(content); end
  end
end

