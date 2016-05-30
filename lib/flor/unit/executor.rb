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

      t0 = Time.now

      (@unit.conf['exe_max_messages'] || 77).times do |i|

        m = @messages.shift
        break unless m

        point = m['point']

        ms = process(m)

        @consumed << m

        ims, oms = ms.partition { |m| m['exid'] == @exid }
          # qui est "in", qui est "out"?

        @messages.concat(ims)
        @unit.storage.put_messages(oms)
      end

      @unit.storage.consume(@consumed)

      @alive = false

      @execution['counters']['runs'] ||= 0
      @execution['counters']['runs'] += 1

      p [
        self.class, self.hash, @exid,
        { took: Time.now - t0, consumed: @consumed.size,
          counters: @execution['counters'] }
      ] if @unit.conf['log_run']

      @unit.storage.put_execution(@execution)
      @unit.storage.put_messages(@messages)

    rescue => e
# TODO
puts "=" * 80
p e
puts e.backtrace
puts ("=" * 80) + ' .'
    end

    def failed(message)

      pp message if @unit.conf['log_err']

      []
    end

    def terminated(message)

      # nothing to do

      []
    end

    def ceased(message)

      # nothing to do

      []
    end

    def cancel(message)

      apply(
        @execution['nodes'][message['nid']],
        message)
    end

    def schedule(message)

      @unit.storage.put_timer(message)

      []
    end
  end
end

