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
    end

    def alive?; @alive; end

    def run

      Thread.new { do_run }

      self
    end

    protected

    def do_run

      counter_next('runs')

      t0 = Time.now

      (@unit.conf['exe_max_messages'] || 77).times do |i|

        m = @messages.shift
        break unless m

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

      puts(
        Flor::Colours.dark_grey + '---' +
        [
          self.class, self.hash, @exid,
          { took: Time.now - t0,
            consumed: @consumed.size,
            traps: @traps.size,
            #own_traps: @traps.reject { |t| t.texid == nil }.size, # FIXME
            counters: @execution['counters'] }
        ].inspect +
        '---.' + Flor::Colours.reset
      ) if @unit.conf['log_run']

      @unit.storage.put_execution(@execution)
      @unit.storage.put_messages(@messages)

      @consumed.clear

    rescue => er
# TODO
t = '=e' + Time.now.to_f.to_s.split('.').last
puts '/' + t + ' ' + '=exe' * 17
puts "|#{t} + error in #{self.class}#do_run"
puts "|#{t} #{er.inspect}"
puts "|#{t} db: #{@unit.storage.db.class} #{@unit.storage.db.hash}"
puts "|#{t} thread: #{Thread.current.inspect}"
if @execution
  puts "|#{t} exe:"
  puts "|#{t}   exid: #{@execution['exid'].inspect}"
  puts "|#{t}   counters: #{@execution['counters'].inspect}"
end
if @messages
  puts "|#{t} messages:"
  puts "|#{t}   #{@messages.collect { |m| [ m['mid'], m['point'] ] }.inspect}"
end
er.backtrace.each { |l| puts "|#{t} #{l}" }
puts '\\' + t + ' ' + ('=exe' * 17) + ' .'

    rescue Exception => ex
# TODO
t = '!e' + Time.now.to_f.to_s.split('.').last
puts '/' + t + ' ' + '!exe' * 17
puts "|#{t} + exception in #{self.class}#do_run"
puts "|#{t} #{ex.inspect}"
puts "|#{t} db: #{@unit.storage.db.class} #{@unit.storage.db.hash}"
puts "|#{t} thread: #{Thread.current.inspect}"
if @execution
  puts "|#{t} exe:"
  puts "|#{t}   exid: #{@execution['exid'].inspect}"
  puts "|#{t}   counters: #{@execution['counters'].inspect}"
end
if @messages
  puts "|#{t} messages:"
  puts "|#{t}   #{@messages.collect { |m| [ m['mid'], m['point'] ] }.inspect}"
end
ex.backtrace.each { |l| puts "|#{t} #{l}" }
puts '\\' + t + ' ' + ('!exe' * 17) + ' .'
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

