# frozen_string_literal: true

require 'zlib'


module Flor

  class Storage

    MESSAGE_COLUMNS = [
      :domain, :exid, :point, :content,
      :status, :ctime, :mtime, :cunit, :munit
        ].freeze
    POINTER_COLUMNS = [
      :domain, :exid, :nid, :type, :name, :value, :ctime, :cunit,
        :content
          ].freeze

    attr_reader :unit, :db, :models

    attr_reader :mutex
      # might be useful for some implementations

    attr_accessor :archive

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

    def db_version(opts={})

      table, column = migration_table_and_column(opts)

      (@db[table].first rescue {})[column]
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

    def synchronize(on=true, &block)

      Thread.current[:sto_errored_items] = nil if on

      if @mutex && on
        @mutex.synchronize(&block)
      else
        block.call
      end
    end

    def transync(on=true, &block)

      Thread.current[:sto_errored_items] = nil if on

      if @mutex && on
        @mutex.synchronize { @db.transaction(&block) }
      else
        block.call
      end
    end

    def migrate(to=nil, from=nil, opts=nil)

      opts = [ to, from, opts ].find { |e| e.is_a?(Hash) } || {}
      opts[:target] ||= to if to.is_a?(Integer)
      opts[:current] ||= from if from.is_a?(Integer)

      opts[:table], opts[:column] = migration_table_and_column(opts)
        #
        # defaults for the migration version table:
        # { table: :schema_info,
        #   column: :version }

      skip =
        opts[:sparse_migrations] ||
        @unit.conf['db_sparse_migrations'] ||
        @unit.conf['sto_sparse_migrations']
      if skip && ! opts.has_key?(:allow_missing_migration_files)
        opts[:allow_missing_migration_files] = true
      end

      dir =
        opts[:migrations] ||
        opts[:migration_dir] ||
        @unit.conf['db_migrations'] ||
        @unit.conf['db_migration_dir'] ||
        @unit.conf['sto_migrations'] ||
        @unit.conf['sto_migration_dir'] ||
        Flor.migration_dir

      synchronize do

        Sequel::Migrator.run(@db, dir, opts)
      end
    end

    # Delete tables in the storage database that begin with "flor_"
    # and have more than 2 columns (the Sequel schema_info table has 1 column
    # as of this writing)
    #
    def delete_tables

      @db.tables.each { |t|
        @db[t].delete \
          if t.to_s.match(/^flor_/) && @db[t].columns.size > 2 }
    end

    def load_execution(exid)

      synchronize do

        e = @db[:flor_executions]
          .select(:id, :content)
          .first(exid: exid) # status active or terminated doesn't matter

        return {
          'exid' => exid, 'nodes' => {}, 'counters' => {},
          'start' => Flor.tstamp, 'size' => 0
        } unless e

        ex = from_blob(e[:content])

        fail("couldn't parse execution (db id #{e[:id].to_i})") unless ex

        ex['id'] = e[:id].to_i
        ex['size'] = e[:content].size

        ex
      end
    end

    def put_execution(exe)

      status =
        exe['nodes'].find { |_, n| n['status'].last['status'] != 'ended' } ?
        'active' :
        'terminated'

      id = exe['id']

      if id

        exe['end'] ||= Flor.tstamp \
          if status == 'terminated'
        exe['duration'] = Time.parse(exe['end']) - Time.parse(exe['start']) \
          if exe['end']
      end

      data = to_blob(exe)
      exe['size'] = data.size

      u = @unit.identifier

      transync do

        now = Flor.tstamp

        if id

          @db[:flor_executions]
            .where(id: id.to_i)
            .update(
              content: data,
              status: status,
              mtime: now,
              munit: u)

        else

          exe['id'] =
            @db[:flor_executions]
              .insert(
                domain: Flor.domain(exe['exid']),
                exid: exe['exid'],
                content: data,
                status: status,
                ctime: now,
                mtime: now,
                cunit: u,
                munit: u)
              .to_i
        end

        remove_nodes(exe, status, now)
        update_pointers(exe, status, now)
      end

      exe
        # return the execution hash

    rescue => err

      Thread.current[:sto_errored_items] = [ exe ]
      raise err
    end

    def load_messages(exe_count)

      exe_count += 2
        # load two more, could prove useful if they vanish like "petits pains"

      synchronize do

        _exids_being_processed =
          @db[:flor_messages]
            .select(:exid)
            .exclude(status: %w[ created consumed ])
        _exids =
          @db[:flor_messages]
            .select(:exid)
            .exclude(exid: _exids_being_processed)
            .exclude(status: %w[ reserved consumed ])
            .limit(exe_count)
        @db[:flor_messages]
          .where(exid: _exids, status: 'created')
          .inject({}) { |h, m| (h[m[:exid]] ||= []) << m; h }
      end

    rescue => err

      @unit.logger.warn(
        "#{self.class}#load_messages()", err, '(returning {})')

      {}
    end

    def reserve_all_messages(messages)

      now = Flor.tstamp
      count = 0

      transync do

        messages.each do |m|

          c = @db[:flor_messages]
            .where(
              id: m[:id].to_i, status: 'created',
              mtime: m[:mtime], munit: m[:munit])
            .update(
              status: 'reserved', mtime: now, munit: @unit.identifier)

          raise Sequel::Rollback if c != 1

          count += 1
        end
      end

      count == messages.size
        # true means success: all the messages could be reserved,
        # executor is clear to work on the execution

    rescue => err

      @unit.logger.warn(
        "#{self.class}#reserve_all_messages()", err, '(returning false)')

      false
        # failure
    end

    def any_message?

      synchronize do

        @db[:flor_messages].where(status: 'created').count > 0
      end

    rescue => err

      @unit.logger.warn(
        "#{self.class}#any_message?()", err, '(returning false)')

      false
    end

    def fetch_traps(exid)

      synchronize do

        traps
          .where(status: 'active')
          .where(domain: split_domain(exid))
          .all
      end

    rescue => err

      @unit.logger.warn(
        "#{self.class}#fetch_traps()", err, '(returning [])')

      []
    end

    POINTS_TO_ARCHIVE = %w[ terminated failed ceased ]

    def consume(messages)

      if @archive
        consume_and_archive(messages)
      else
        consume_and_discard(messages)
      end

    rescue => err

      Thread.current[:sto_errored_items] = messages
      raise err
    end

    def put_messages(ms, syn=true)

      return if ms.empty?

      n = Flor.tstamp
      u = @unit.identifier

      id =
        synchronize(syn) do

          stored, unstored = ms.partition { |m| m['mid'] }

          #
          # de-reserve any previously stored message, might happen
          # for "terminated" messages that got queued back to let
          # other messages get processed

          @db[:flor_messages]
            .where(id: stored.collect { |m| m['mid'] })
            .update(status: 'created', mtime: n, munit: u) \
              if stored.any?

          #
          # store new messages

          @db[:flor_messages]
            .import(
              MESSAGE_COLUMNS,
              unstored.map { |m|
                [ Flor.domain(m['exid']), m['exid'], m['point'], to_blob(m),
                  'created', n, n, u, u ] }) \
                    if unstored.any?

          @db[:flor_messages].max(:id)
        end

      @unit.wake_up

      id

    rescue => err

      Thread.current[:sto_errored_items] = ms
      raise err
    end

    def put_message(m)

      put_messages([ m ])
    end

    def unreserve_messages(max_sec)

      tstamp = Flor.tstamp(Time.now - max_sec)
      tstamp = tstamp[0..tstamp.rindex('.')]

      synchronize do

        @db[:flor_messages]
          .where(status: 'reserved')
          .where { mtime < tstamp }
          .update(status: 'created')
      end

    rescue => err

      @unit.logger.warn(
        "#{self.class}#unreserve_messages(#{max_sec})", err, '(returning nil)')

      -1 # not zero, to indicate a problem
    end

    def put_timer(message)

      type, string = determine_type_and_schedule(message)

      next_time = compute_next_time(type, string)

      now = Flor.tstamp
      u = @unit.identifier

      synchronize do

        @db[:flor_timers]
          .insert(
            domain: Flor.domain(message['exid']),
            exid: message['exid'],
            nid: message['nid'],
            onid: message['onid'] || message['nid'],
            bnid: message['nid'],
            type: type,
            schedule: string,
            ntime: next_time,
            content: to_blob(message),
            count: 0,
            status: 'active',
            ctime: now,
            mtime: now,
            cunit: u,
            munit: u)
      end

      @unit.wake_up

    rescue => err

      Thread.current[:sto_errored_items] = [ message ]
      raise err
    end

    def trigger_timers

      synchronize do

        load_timers.each do |t|

          @db.transaction do

            next unless reschedule_timer(t) == 1

            trigger_timer(t)
          end
        end
      end
    end

    def put_trap(node, tra)

      exid = node['exid']
      dom = Flor.domain(exid)
      now = Flor.tstamp
      u = @unit.identifier

      id =
        synchronize do

    #points = att_a('point', 'points', nil)  ### TODO
    #tags = att_a('tag', 'tags', nil)        #
    #heats = att_a('heat', 'heats', nil)     #
    #heaps = att_a('heap', 'heaps', nil)     #
    #names = att_a('name', 'names', nil)     #
        #
      #opts[:heap] = theaps.split(',') if theaps
      #opts[:heat] = theats.split(',') if theats
            #
          @db[:flor_traps]
            .insert(
              domain: dom,
              exid: exid,
              nid: tra['nid'],
              onid: tra['onid'] || tra['nid'],
              bnid: tra['bnid'],
              trange: tra['range'],
              tpoints: commaify(tra['points']),
              ttags: commaify(tra['tags']),
              theats: commaify(tra['heats']),
              theaps: commaify(tra['heaps']),
              content: to_blob(tra),
              status: 'active',
              ctime: now,
              mtime: now,
              cunit: u,
              munit: u)
        end

      traps[id]

    rescue => err

      Thread.current[:sto_errored_items] = [ node, tra ]
      raise err
    end

    def trace(exid, nid, tracer, text)

      text = text.is_a?(String) ? text : JSON.dump(text)

      synchronize do

        @db[:flor_traces]
          .insert(
            domain: Flor.domain(exid),
            exid: exid,
            nid: nid,
            tracer: tracer,
            text: text,
            ctime: Flor.tstamp,
            cunit: @unit.identifier)
      end
    end

    def fetch_next_time

      t =
        synchronize do
          @db[:flor_timers]
            .select(:ntime)
            .order(:ntime)
            .first(status: 'active')
        end

      t ? t[:ntime].split('.').first : nil

    rescue => err

      @unit.logger.warn(
        "#{self.class}#fetch_next_time()", err, '(returning nil)')

      nil
    end

    protected

    def migration_table_and_column(opts={})

      [ (opts[:migration_table] ||
         @unit.conf['db_migration_table'] ||
         @unit.conf['sto_migration_table'] ||
         :schema_info).to_sym,
        (opts[:migration_column] ||
          @unit.conf['db_migration_column'] ||
          @unit.conf['sto_migration_column'] ||
          :version).to_sym ]
    end

    def _commaify(o)

      if Flor.is_regex_tree?(o)
        o[1].to_s
      else #if o.is_a?(String)
        o.split(/\s*,\s*/).join(',')
      end
    end

    def commaify(o)

      return nil unless o

      o = [ o ] if Flor.is_regex_tree?(o)
      o = [ o ] unless o.is_a?(Array)

      o.collect { |e| _commaify(e) }.join(',')
    end

    def consume_and_archive(messages)

      transync do

        n = Flor.tstamp
        u = @unit.identifier

        @db[:flor_messages]
          .where(
            id: messages.collect { |m| m['mid'] }.uniq.compact)
          .update(
            status: 'consumed', mtime: n, munit: u)

        @db[:flor_messages]
          .import(
            MESSAGE_COLUMNS,
            messages
              .select { |m|
                ! m['mid'] && POINTS_TO_ARCHIVE.include?(m['point']) }
              .map { |m|
                [ Flor.domain(m['exid']), m['exid'], m['point'], to_blob(m),
                  'consumed', n, n, u, u ] })
      end
    end

    def consume_and_discard(messages)

      synchronize do

        @db[:flor_messages]
          .where(
            id: messages.collect { |m| m['mid'] }.uniq.compact)
          .delete
      end
    end

    def load_timers

      timers
        .where(status: 'active')
        .where { ntime <= Flor.tstam }
        .order(:ntime)
        .all

    rescue => err

      @unit.logger.warn("#{self.class}#load_timers()", err, '(returning [])')

      []
    end

    def trigger_timer(t)

      put_messages([ t.to_trigger_message ], false)
    end

    def reschedule_timer(t)

      w = { id: t.id.to_i, status: 'active', mtime: t.mtime, munit: t.munit }

      if t.type != 'at' && t.type != 'in'

        @db[:flor_timers]
          .where(w)
          .update(
            count: t.count.to_i + 1,
            status: 'active',
            ntime: compute_next_time(t.type, t.schedule, t.ntime_t),
            mtime: Flor.tstamp,
            munit: @unit.identifier)

      elsif @archive

        @db[:flor_timers]
          .where(w)
          .update(
            count: t.count.to_i + 1,
            status: 'triggered',
            mtime: Flor.tstamp,
            munit: @unit.identifier)

      else

        @db[:flor_timers]
          .where(w)
          .delete
      end
    end

    def remove_nodes(exe, status, now)

      exid = exe['exid']

      x = (status == 'terminated') ? {} : { nid: exe['nodes'].keys }
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

# Q  Should we archive old pointers?
# A  Well, it might be better to only archive the execution and leave
#    in there enough information...

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
      u = @unit.identifier

      pointers = exe['nodes']
        .inject([]) { |a, (nid, node)|

          ts = node['tags']
          ts.each { |t|
            a << [ dom, exid, nid, 'tag', t, nil, now, u, nil ] } if ts

          vs = nid == '0' ? node['vars'] : nil
          vs.each { |k, v|
            case v; when Numeric, String, TrueClass, FalseClass, NilClass
              a << [ dom, exid, '0', 'var', k, v.to_s, now, u, v ]
            when Array, Hash
              s = '(array)'; s = '(object)' if v.is_a?(Hash)
              a << [ dom, exid, '0', 'var', k, s, now, u, v ]
            else
              a << [ dom, exid, '0', 'var', k, nil, now, u, v ]
            end } if vs

          if ta = node['task']
            tasker = ta['tasker']
            n = ta['name']; name = n.is_a?(String) ? n : JSON.dump(n)
            content = { message: node['message'], atts: node['atts'] }
            a << [ dom, exid, nid, 'tasker', tasker, name, now, u, content ]
          end

          a }

      cps = @db[:flor_pointers] # current pointers
        .where(exid: exid)
        .select(:nid, :type, :name)
        .all
      pointers.reject! { |_, _, ni, ty, na, _, _, _, _|
        cps.find { |cp| cp[:nid] == ni && cp[:type] == ty && cp[:name] == na } }
          #
          # don't insert when already inserted

      #if pointer_columns.include?(:content)
      pointers.each { |ptr| c = ptr[8]; ptr[8] = to_blob(c) if c }
      #else
      #  pointers.each { |ptr| ptr.pop }
      #end

      #@db[:flor_pointers]
      #  .import(
      #    pointer_columns,
      #    pointers)
      @db[:flor_pointers]
        .import(
          POINTER_COLUMNS,
          pointers)
    end

    #def pointer_columns
    #  @pointer_columns ||=
    #    if @db[:flor_pointers].columns.include?(:content)
    #      POINTER_COLUMNS + [ :content ]
    #    else
    #      POINTER_COLUMNS
    #    end
    #end

    def determine_type_and_schedule(message)

      t, s = message['type'], message['string']
      return [ t, s ] if t

      t = Fugit.determine_type(s)
      return [ t, s ] if t

      s = "every #{s}"
      return [ 'cron', s ] if Fugit.parse_nat(s)

      nil
    end

    def compute_next_time(type, string, from=nil)

      f =
        case type
        when 'cron' then Fugit.parse_cron(string) || Fugit.parse_nat(string)
        when 'at' then Fugit.parse_at(string)
        when 'in' then Fugit.parse_duration(string)
        #when 'every' then Fugit.parse_duration(string)
        else Fugit.parse(string)
        end

      nt = f.is_a?(Time) ? f : f.next_time(from || Time.now) # local...

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

    def derive_db

      db = @unit.conf['sto_db']

      return db if db

      uri = @unit.conf['sto_uri']

      fail ArgumentError.new("no 'sto_uri' conf, cannot connect to db") \
        unless uri

      return Kernel.const_get(uri) \
        if uri.is_a?(String) && uri.match(/\A[A-Z]+\z/)
          # for cases where uri == 'DB'

      Sequel.connect(uri)
    end

    def connect

      @db = derive_db

      class << @db; attr_accessor :flor_unit; end
      @db.flor_unit = @unit

      if cv = @unit.conf['sto_connection_validation']

        to = cv.is_a?(Numeric) || cv.is_a?(String) ? cv.to_i : -1

        @db.extension(:connection_validator)
        @db.pool.connection_validation_timeout = to
          # NB: -1 means "check at every use"
      end

      if @unit.conf['sto_db_logger'] != false

        @db_logger = DbLogger.new(@unit)
        @db.loggers << @db_logger
      end
    end

    class << self

      def to_blob(h)

        h ? Sequel.blob(Zlib::Deflate.deflate(JSON.dump(h))) : nil
#rescue => e; pp h; raise e
      end

      def from_blob(content)

        content ? JSON.parse(Zlib::Inflate.inflate(content)) : nil
      end
    end

    def to_blob(h); self.class.to_blob(h); end
    def from_blob(content); self.class.from_blob(content); end
  end

  # module Flor

  class << self

    def to_blob(h); ::Flor::Storage.to_blob(h); end
    def from_blob(content); ::Flor::Storage.from_blob(content); end
  end
end

