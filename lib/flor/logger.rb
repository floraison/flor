
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


class Flor::Logger

  def initialize(unit)

    @unit = unit

    @waiter_cb = WaiterCallback.new
    @callbacks = [ @waiter_cb ]
  end

  def log(msg)

    puts "** logger * #{msg.inspect}"
    @callbacks.each { |cb| cb.feed(msg) }
  end

  def wait(exid, point, opts) # :nid, :maxsec

    @waiter_cb.register(exid, point, opts)
  end

  class WaiterCallback

    def initialize

      @waiters = []
    end

    def register(exid, point, opts)

      @waiters << Waiter.new(exid, point, opts)

      @waiters.last.wait
    end

    def feed(msg)

      @waiters = @waiters.select(&:queue)
      @waiters.each { |w| w.feed(msg) }
    end

    class Waiter

      attr_reader :exid, :point, :nid
      attr_reader :queue

      def initialize(exid, point, opts)

        @exid = exid
        @point = point
        @nid = opts[:nid]
        @maxsec = opts[:maxsec] || 3

        @queue = Queue.new
      end

      def wait

        Thread.new do
          begin
            sleep @maxsec
            @queue.push(:timed_out) if @queue
          rescue => err
            # nada
          end
        end if @maxsec > 0

        r = @queue.pop
        @queue = nil

        r
      end

      def feed(msg)

        return if @exid && @exid != msg['exid']
        return if @point && @point != msg['point']
        return if @nid && @nid != msg['nid']

        @queue << msg
      end
    end
  end
end

