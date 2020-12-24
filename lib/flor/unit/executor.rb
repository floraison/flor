# frozen_string_literal: true

module Flor

  class UnitExecutor < Flor::Executor

    attr_reader :exid
    attr_reader :consumed

    def initialize(unit, messages)

      @exid = messages.first[:exid]

      super(
        unit,
        unit.loader.load_hooks(@exid),
        unit.storage.fetch_traps(@exid),
        unit.storage.load_execution(@exid))

      @messages = messages
        .collect { |m|
          Flor::Storage
            .from_blob(m[:content])
            .tap { |mm| mm['mid'] = m[:id].to_i } }
      @consumed = []

      @alive = true
      @shutdown = false

      @thread = nil
    end

    def alive?; @alive; end

    def run

      @thread = Thread.new { do_run }
#p [ :unit_executor, :thread, @thread.object_id ]

      self
    end

    def shutdown

      @shutdown = true
      @thread.join
    end

    protected

    CLOSING_POINTS = %w[ task terminated ceased ]
      #
      # point for messages that, after consumption, are conserved
      # in the execution's "closing_messages" array

    def do_run

      @unit.logger.log_run_start(self)

      counter_next('runs')

      t0 = Time.now

      (@unit.conf['exe_max_messages'] || 77).times do |i|

        break if @shutdown

        m = @messages.shift
        break unless m

        m = (@messages << m).shift \
          if m['point'] == 'terminated' && @messages.any?
            #
            # handle 'terminated' messages last

        ms = process(m)

        @consumed << m

        ims, oms = ms.partition { |mm| mm['exid'] == @exid }
          # qui est "in", qui est "out"?

        counter_add('omsgs', oms.size)
          # keep track of "out" messages, messages to other executions

        @messages.concat(ims)
        @unit.storage.put_messages(oms)
      end

      @alive = false

      @execution.merge!(
        closing_messages: @consumed.select { |m|
          CLOSING_POINTS.include?(m['point']) })

      @unit.storage.put_execution(@execution)
      @unit.storage.consume(@consumed)

      @unit.storage.put_messages(@messages)

      du = Time.now - t0
      t0 = Flor.tstamp(t0)

      @unit.logger.log_run_end(self, t0, du)
      @unit.hooker.notify(self, make_end_message(t0, du, @execution['size']))

      @consumed.clear

    rescue Exception => exc

# TODO eventually, have a dump dir
      fn =
        [
          'flor',
          @unit.conf['env'], @unit.identifier, @exid,
          'r' + counter('runs').to_s
        ].collect(&:to_s).join('_') + '.dump'

      @unit.logger.error(
        "#{self.class}#do_run()", exc, "(dumping to #{fn} ...)")

      File.open(fn, 'wb') do |f|
        f.puts(Flor.to_pretty_s({
          execution: @execution,
          messages: @messages,
          consumed: @consumed,
          traps: @traps.collect(&:to_h),
          exid: @exid,
          alive: @alive,
          shutdown: @shutdown,
          thread: [ @thread.object_id, @thread.to_s ]
        }))
        f.puts('-' * 80)
        f.puts(on_do_run_exc(exc))
      end

      @unit.logger.error(
        "#{self.class}#do_run()", exc, "(dumped to #{fn})")

      #puts on_do_run_exc(exc)
        # dump notification above
    end

    def task(message)

      if message['routed'] == false

        t = message['tasker']
        n = node(message['nid'])

        msg = n['heat0'] != t ?
          "tasker #{t.inspect} not found" :
          "don't know how to apply #{t.inspect}"

        return error_reply(n, message, msg)
      end

      @unit.ganger.task(self, message)
    end
    alias detask task

    def return(message)

      n = @execution['nodes'][message['nid']] || {}
      m = n['message'] || {}
      c = m['cause']

      rm = message.dup
      rm['point'] = 'receive'
      rm['cause'] = c if c # preserve 'cause' for routing

      [ rm ]
    end

    def schedule(message)

      @unit.schedule(message)

      []
    end

    def trigger(message)

      m = message['message']
      m['cause'] = message['cause']

      m['nid'] = Flor.sub_nid(m['nid'], counter_next('subs')) \
        if m['point'] == 'execute'

      [ m ]
    end

    def add(message)

      apply(@execution['nodes'][message['nid']], message)
    end

    def on_do_run_exc(e)

      io = StringIO.new
      thr = Thread.current

      head, kind =
        e.is_a?(StandardError) ? [ '=exe', 'error' ] : [ '!exe', 'exception' ]

      t = head[0, 2] + Time.now.to_f.to_s.split('.').last
      io.puts ' /' + t + ' ' + head * 17
      io.puts " |#{t} + in #{self.class}#do_run"
      io.puts " |#{t} #{kind}: #{e.inspect}"
      io.puts " |#{t} db:  #{@unit.storage.db.class} #{@unit.storage.db.hash}"
      io.puts " |#{t} thread: t#{thr.object_id} #{thr.inspect}"
      if @execution
        io.puts " |#{t} exe:"
        io.puts " |#{t}   exid: #{@execution['exid'].inspect}"
        io.puts " |#{t}   counters: #{@execution['counters'].inspect}"
      end
      if @messages
        io.puts " |#{t} messages:"
        io.puts " |#{t}   #{@messages.map { |m| [ m['mid'], m['point'] ] }.inspect}"
      end
      if is = Thread.current[:sto_errored_items]
        io.puts " |#{t} storage errored items/models:"
        is.each do |i|
          io.puts " |#{t}   * #{i.inspect}"
        end
      end
      io.puts " |#{t} #{kind}: #{e.inspect}"
      io.puts " |#{t} backtrace:"
      e.backtrace.each { |l| io.puts "|#{t} #{l}" }
      io.puts ' \\' + t + ' ' + (head * 17) + ' .'

      io.string
    end

    def make_end_message(start, duration, execution_size)

      m = {}
      m['point'] = 'end'
      m['exid'] = @exid
      m['start'] = start
      m['duration'] = "#{duration}s"
      m['consumed'] = @consumed.size
      m['counters'] = Flor.dup(@execution['counters'])
      m['nodes'] = @execution['nodes'].size
      m['execution_size'] = execution_size
      m['archive_size'] = @unit.archive[@exid].size if @unit.archive
      m['er'] = @execution['counters']['runs'] # "emitting run"
      m['pr'] = m['er'] # "processing run"

      m
    end
  end
end

