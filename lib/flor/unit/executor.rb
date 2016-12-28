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


module Flor

  class UnitExecutor < Flor::Executor

    attr_reader :exid

    def initialize(unit, exid)

      super(
        unit,
        unit.storage.fetch_traps(exid),
        unit.storage.load_execution(exid))

      @exid = exid
      @messages = unit.storage.fetch_messages(exid)
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

    def do_run

      puts(
        Flor::Colours.dark_grey + '--- new run ' +
        [
          self.class, self.object_id, @exid,
          { exid: @exid,
            thread: Thread.current.object_id,
            counters: @execution['counters'],
            nodes: @execution['nodes'].size,
            size: @execution['size'] }
        ].inspect +
        '---.' + Flor::Colours.reset
      ) if @unit.conf['log_run']

      counter_next('runs')

      t0 = Time.now

      (@unit.conf['exe_max_messages'] || 77).times do |i|

        m = @messages.shift
        break unless m
        break if @shutdown

        if m['point'] == 'terminated' && @messages.any?
          #
          # try to handle 'terminated' last
          #
          @messages << m
          m = @messages.shift
        end

        point = m['point']

        ms = process(m)

        @consumed << m
          #
        #@consumed << m unless ms.include?(m)
          # TODO what if msg is held / pushed back?

        ims, oms = ms.partition { |m| m['exid'] == @exid }
          # qui est "in", qui est "out"?

        counter_add('omsgs', oms.size)
          # keep track of "out" messages, messages to other executions

        @messages.concat(ims)
        @unit.storage.put_messages(oms)
      end

      @unit.storage.consume(@consumed)

      @alive = false

      x = @unit.storage.put_execution(@execution)
      @unit.storage.put_messages(@messages)

      puts(
        Flor::Colours.dark_grey + '--- run over ' +
        [
          self.class, self.object_id, @exid,
          { took: Time.now - t0,
            thread: Thread.current.object_id,
            consumed: @consumed.size,
            traps: @traps.size,
            #own_traps: @traps.reject { |t| t.texid == nil }.size, # FIXME
            counters: @execution['counters'],
            nodes: @execution['nodes'].size,
            size: x['size'] }
        ].inspect +
        '---.' + Flor::Colours.reset
      ) if @unit.conf['log_run']

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
        "#{self.class}#do_run()", exc, "(dumping to #{fn})")

      File.open(fn, 'wb') do |f|
        #f.puts(JSON.pretty_generate({
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

      puts on_do_run_exc(exc)
    end

    def schedule(message)

      @unit.put_timer(message)

      []
    end

    def trigger(message)

      m = message['message']

      m['nid'] = Flor.sub_nid(m['nid'], counter_next('subs')) \
        if m['point'] == 'execute'

      [ m ]
    end
  end
end

