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

  class Waiter

    # NB: logger configuration entries start with "wai_"

    def initialize(unit)

      @unit = unit

      @mutex = Mutex.new
      @entries = []
    end

    def shutdown

      # TODO
    end

    def message(message)

      @mutex.synchronize do

        @entries
          .select { |e| e.match?(message) }
          .each { |e|
            e.push(message)
            @entries.delete(e) unless e.repeat
          }
      end
    end

    def wait(exid, points=nil, repeat=false)

      e = Entry.new(exid, points, repeat)
      @mutex.synchronize { @entries << e }

      e.wait
    end

    class Entry

      attr_reader :exid, :points, :repeat, :queue

      def initialize(exid, points, repeat)

        @exid = exid
        @points = points
        @repeat = repeat

        @queue = []
        @mutex = Mutex.new
        @var = ConditionVariable.new
      end

      def match?(message)

        ((@exid && message['exid'] == @exid) || @exid == nil) &&
        ((@points && @points.include?(message['point'])) || @points == nil)
      end

      def push(x)

        @mutex.synchronize do
          @queue.push(x)
          @var.signal
        end

        self
      end

      def wait(timeout=3)

        @mutex.synchronize do

          if @queue.empty?
            @var.wait(@mutex, timeout) if timeout > 0
            fail(RuntimeError, "timeout for #{self.to_s}") if @queue.empty?
          end
          @queue.shift
        end
      end

      def to_s

        self.class.to_s +
        "(exid:#{@exid.inspect},points:#{@points.inspect},repeat:#{@repeat})"
      end
    end
  end
end

