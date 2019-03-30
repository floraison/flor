
module Flor

  class Scheduler

    attr_reader :conf, :env

    attr_reader :hooker, :storage, :loader, :ganger, :caller
    attr_reader :logger

    attr_reader :thread_status

    attr_reader :archive

    def initialize(conf={}, over_conf={})

      @conf = Flor::Conf.prepare(conf, over_conf)

      fail ArgumentError.new(
        "invalid domain name #{@conf['domain']}"
      ) if @conf['domain'] && ! Flor.potential_domain_name?(@conf['domain'])

      @env = @conf['env'] ||= 'dev'

      @env = (Kernel.const_get(@env) rescue @env) if @env.match(/\A[A-Z]+\z/)
        # when env is "RAILS_ENV" for example...

      @loader =
        (Flor::Conf.get_class(@conf, 'loader') || Flor::Loader).new(self)
      @caller =
        (Flor::Conf.get_class(@conf, 'caller') || Flor::Caller).new(self)
      @hooker =
        (Flor::Conf.get_class(@conf, 'hooker') || Flor::Hooker).new(self)
      @storage =
        (Flor::Conf.get_class(@conf, 'storage') || Flor::Storage).new(self)
      @ganger =
        (Flor::Conf.get_class(@conf, 'ganger') || Flor::Ganger).new(self)

      @logger =
        (Flor::Conf.get_class(@conf, 'logger') || Flor::Logger).new(self)
      @wlist =
        (Flor::Conf.get_class(@conf, 'wlist') || Flor::WaitList).new(self)

      @spooler =
        (Flor::Conf.get_class(@conf, 'spooler') || Flor::Spooler).new(self)

      @heart_rate = @conf[:sch_heart_rate] || 0.3
      @reload_after = @conf[:sch_reload_after] || 60
        #
      @wake_up = true
      @next_time = nil
      @reloaded_at = Time.now

      @msg_max_res_time = @conf[:sch_msg_max_res_time] || 10 * 60

      @idle_count = 0

      @max_executors = @conf[:sch_max_executors] || 1
        #
      @executors = []

      c = @conf['constant']
        #
      Kernel.const_set(c, self) if c

      @archive = @conf['archive'] ? {} : nil # used, so far, only for testing
    end

    def name

      @conf['unit'] || @conf['uni_name'] || 'u0'
    end

    def storage_mutex

      @storage.mutex
    end

    def identifier

      @identifier ||=
        begin
          ai =
            Socket.ip_address_list.find { |a| a.ipv4_private? } ||
            Socket.ip_address_list.find { |a| a.ip_address != '::1' }
          ip =
            (ai ? ai.ip_address : '::1').split('%').first
          [
            'sch', self.name,
            'i' + ip,
            'p' + Process.pid.to_s,
            'o' + (self.object_id % 100_000).to_s(32)
          ].join('-')
        end
    end

    def has_tasker?(exid, tname)

      @ganger.has_tasker?(exid, tname)
    end

    def shutdown

      @thread_status = :shutdown
      @thread = nil

      @executors.each(&:shutdown)

      @hooker.shutdown
      @storage.shutdown
      @ganger.shutdown
    end

    def hook(*args, &block)

      @hooker.add(*args, &block)
    end

    def on_start_exc(e)

      io = StringIO.new

      head, kind =
        e.is_a?(StandardError) ? [ '=sch', 'error' ] : [ '!sch', 'exception' ]
      thr = Thread.current

      t = head[0, 2] + Time.now.to_f.to_s.split('.').last
      io.puts ' /' + t + ' ' + head * 17
      io.puts " |#{t} + in #{self.class}#start"
      io.puts " |#{t} db: #{@storage.db.class} #{@storage.db.object_id}"
      io.puts " |#{t} thread: t#{thr.object_id} #{thr.inspect}"
      io.puts " |#{t} #{kind}: #{e.inspect}"
      io.puts " |#{t} backtrace:"
      e.backtrace.each { |l| io.puts "|#{t} #{l}" }
      io.puts ' \\' + t + ' ' + (head * 17) + ' .'

      io.string
    end

    def start

      # TODO heartbeat, every x minutes, when idle, log something

      fail(
        "database not ready, " +
        "db ver: #{@storage.db_version.inspect}, " +
        "mig ver: #{@storage.migration_version}"
      ) if !! @conf['sto_migration_check'] && @storage.ready?

      @thread_status = :running

      @thread =
        if defined?(@thread) && @thread
          @thread.run
        else
          Thread.new do
            loop do
              Thread.stop if @thread_status == :stop
              break if @thread_status == :shutdown
              tick
            end
          end
        end

      self
    end

    def stop

      @thread_status = :stop
    end

    def running?; @thread_status == :running; end
    def stopped?; ! running?; end

    def join

      @thread.join
    end

    def launch(source_or_path, opts={})

      source, domain, flow_name =
        if df = Flor.split_flow_name(source_or_path)
          [ source_or_path, opts[:domain] || df[0], df[1] ]
        else
          [ source_or_path, opts[:domain] || @conf['domain'] || 'domain0', nil ]
        end

      fail ArgumentError.new(
        "invalid domain name #{domain.inspect}"
      ) unless Flor.potential_domain_name?(domain)

      if flow_name

        source_path, source = @loader.library(source_or_path)

        opts[:fname] = source_path

        # TODO variables
        #        loaded as needed, via the loader
        # TODO payload
        #        yes, still has to be done
      end

      fail ArgumentError.new(
        "flow not found in #{Flor.truncate_string(source_or_path, 35).inspect}"
      ) unless source # will anyway fail badly if src is a tree (array of ...)

      @archive ||= {} if opts[:archive]
        # all subsequent launches will be `archive: true` ...

      @logger.log_src(source, opts)

      unit = opts[:unit] || self.name

      exid = Flor.generate_exid(domain, unit)
      msg = Flor.make_launch_msg(exid, source, opts)

      @logger.log_tree(msg['tree'])

      return [ msg, opts ] if opts[:nolaunch]
        # for testing purposes

      queue(msg, opts)
    end

    def queue(message, opts={})

      @storage.put_message(message)

      if opts[:wait]
        wait(message['exid'], opts)
      else
        message['exid']
      end
    end

    def return(message)

      m =
        if message['point'] == 'failed'
          message
        else
          message
            .select { |k, _| %w[ exid nid payload tasker ].include?(k) }
            .merge!('point' => 'return')
        end

      queue(m)

      nil
    end

    def cancel(exid, *as)

      queue(*prepare_message('cancel', [ exid, *as ]))
    end

    def kill(exid, *as)

      queue(*prepare_message('kill', [ exid, *as ]))
    end

    def signal(name, h={})

      h[:payload] ||= {}
      h[:name] ||= name

      queue(*prepare_message('signal', [ h ]))
    end

    def re_apply(exid, *as)

      queue(*prepare_message('cancel', [ exid, *as, { re_apply: true } ]))
    end
    alias reapply re_apply

    def add_branches(exid, *as)

      m = prepare_message('add-branches', [ exid, *as ]).first

      exe = @storage.executions[exid: m['exid']]
      pnid = m['nid']
      ptree = exe.lookup_tree(pnid)

      fail ArgumentError.new(
        "parent #{pnid} is a leaf, cannot add branch at #{tnid}"
      ) unless ptree[1].is_a?(Array)
        #
        # not likely to happen, since leaves reply immediately

      size = ptree[1].size
      tnid = (m['tnid'] ||= Flor.make_child_nid(pnid, size))

      cid = Flor.child_id(tnid)

      tide, tcid = nil
        (0..size - 1).reverse_each do |i|
          tcid = Flor.make_child_nid(pnid, i)
          next unless exe.nodes[tcid]
          tide = i; break
        end

      fail ArgumentError.new(
        "target #{tnid} too low, execution has already reached #{tcid}"
      ) if tide && cid < tide

      fail ArgumentError.new(
        "target #{tnid} is off by #{cid - size}, " +
        "node #{pnid} has #{size} branch#{size == 1 ? '' : 'es'}"
      ) if cid > size

      queue(m)
    end
    alias add_branch add_branches

    def add_iterations(exid, *as)

      m = prepare_message('add-iterations', [ exid, *as ]).first

      exe = @storage.executions[exid: m['exid']]
      nid = m['nid']

      fail ArgumentError.new(
        "cannot add iteration to missing execution #{m['exid'].inspect}"
      ) unless exe

      fail ArgumentError.new(
        "missing nid: or pnid:"
      ) unless nid

      fail ArgumentError.new(
        "cannot add iteration to missing node #{nid.inspect}"
      ) unless exe.lookup_tree(nid)

      queue(m)
    end
    alias add_iteration add_iterations

    def schedule(message)

      @storage.put_timer(message)
    end

    def wake_up

      @wake_up = true
    end

    def notify(executor, o)

      if executor
        @hooker.notify(executor, o)
      else
        @hooker.wlist.notify(nil, o)
      end

    rescue => err
      puts '-sch' * 19
      puts "+ error in #{self.class}#notify"
      p err
      puts err.backtrace
      puts ('-sch' * 19) + ' .'
    end

    def trap(node, tra)

      @storage.put_trap(node, tra)
    end

    def archive_node(exid, node)

      (@archive[exid] ||= {})[node['nid']] = Flor.dup(node) if @archive
    end

    def archived_node(exid, nid)

      (@archive[exid] || {})[nid]
    end

    def executor(exid)

      @executors.find { |x| x.exid == exid }
    end

    # Given an exid, returns the execution, if currently executing.
    #
    def execution(exid)

      ex = executor(exid)
      ex ? ex.execution : nil
    end

    protected

    def tick

      t0 = Time.now

      spool

      if should_wake_up?

        unreserve_messages

        trigger_timers
        trigger_executions

        reload_next_time
        reload_wake_up
        @reloaded_at = Time.now

      elsif @executors.empty?

        @idle_count += 1
        notify(nil, make_idle_message)
      end

      sleep [ @heart_rate - (Time.now - t0), 0 ].max #\
        #unless should_wake_up?

    rescue Exception => ex

      puts on_start_exc(ex)
    end

    def prepare_message(point, args)

      h =
        args.inject({}) { |hh, a|
          if a.is_a?(Hash) then a.each { |k, v| hh[k.to_s] = v }
          elsif ! hh.has_key?('exid') then hh['exid'] = a
          elsif ! hh.has_key?('nid') then hh['nid'] = a
          end
          hh }

      msg = { 'point' => point }
      opts = {}

      h.each do |k, v|
        if %w[ exid name nid payload on_receive_last ].include?(k)
          msg[k] = v
        else
          opts[k.to_sym] = v
        end
      end

      if point == 'kill'

        msg['point'] = 'cancel'
        msg['flavour'] = 'kill'

      elsif point == 'add-branches'

        msg['point'] = 'add'
        msg['trees'] = prepare_trees(opts)

        msg['tnid'] = tnid =
          opts.delete(:tnid) || msg.delete('nid')
        msg['nid'] =
          msg.delete('nid') || opts.delete(:pnid) || Flor.parent_nid(tnid)

      elsif point == 'add-iterations'

        msg['point'] = 'add'
        msg['elements'] = prepare_elements(opts)
        msg['nid'] = msg.delete('nid') || opts.delete(:pnid)
      end

      if opts[:re_apply]

        msg['on_receive_last'] = prepare_re_apply_messages(msg, opts)
      end

      fail ArgumentError.new('missing :exid key') \
        unless msg['exid'].is_a?(String)
      fail ArgumentError.new('missing :name string key') \
        if point == 'signal' && ! msg['name'].is_a?(String)

      [ msg, opts ]
    end

    def prepare_trees(opts)

      fname = Flor.caller_fname

      ts = (opts[:trees] || [ opts[:tree] ].compact)
        .collect { |t| Flor.parse(t, fname, {}) }

      fail ArgumentError.new('missing trees: or tree:') if ts.empty?

      ts
    end

    def prepare_elements(opts)

      elts =
        opts[:elements] || opts[:elts] ||
        opts[:element] || opts[:elt]

      fail ArgumentError.new('missing elements: or element:') unless elts

      elts = [ elts ] unless elts.is_a?(Array)

      elts
    end

    def prepare_re_apply_messages(msg, opts)

      fail ArgumentError.new("missing 'payload' to re_apply") \
        unless msg['payload']

      t = Flor.parse(opts[:tree], Flor.caller_fname, {})

      [ { 'point' => 'execute',
          'exid' => msg['exid'], 'nid' => msg['nid'],
          'from' => 'parent',
          'tree' => t,
          'payload' => msg['payload'] } ]
    end

    def make_idle_message

      m = {}
      m['point'] = 'idle'
      m['idle_count'] = @idle_count
      m['consumed'] = true

      m
    end

    def reload_after

      @idle_count < 5 ? 1 : @reload_after
    end

    def should_wake_up?

      return true if @wake_up
      return true if Time.now - @reloaded_at >= reload_after

      @next_time && @next_time <= Flor.tstamp.split('.').first
    end

    def unreserve_messages

      c = @storage.unreserve_messages(@msg_max_res_time)

      @logger.info(
        "#{self.class}#unreserve_messages", "#{c} message#{c > 1 ? 's' : ''}"
      ) if c > 0
    end

    def spool

      count = @spooler.spool
      @wake_up = true if count > 0
    end

    def trigger_timers

      @storage.trigger_timers
    end

    def trigger_executions

      @executors.select! { |e| e.alive? }
        # drop done executors

      free_executor_count = @max_executors - @executors.size

      return if free_executor_count < 1

      messages = @storage.load_messages(free_executor_count)

      messages.each do |exid, ms|

        next unless @storage.reserve_all_messages(ms)

        @idle_count = 0

        @executors << UnitExecutor.new(self, ms).run
      end
    end

    def reload_next_time

      @next_time = @storage.fetch_next_time
    end

    def reload_wake_up

      @wake_up = @storage.any_message?
    end
  end
end

