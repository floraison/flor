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

    def initialize(exid, points, owait, repeat)

      @exid = exid
      @points = points
      @timeout = owait == true ? 3 : owait
      @repeat = repeat

      @queue = []
      @mutex = Mutex.new
      @var = ConditionVariable.new
    end

    def notify(message)

      return false unless match?(message)

      @mutex.synchronize do
        @queue << message
        @var.signal
      end

      ! @repeat
        # returning false: do not remove me, I want to listen/wait further
        # returning true: remove me
    end

    def wait

      @mutex.synchronize do

        if @queue.empty?

          @var.wait(@mutex, @timeout)
            # will wait "as aetername" if @timeout is nil

          fail(RuntimeError, "timeout for #{self.to_s}") if @queue.empty?
        end

        @queue.shift
      end
    end

    protected

    def match?(message)

      return false if @exid && @exid != message['exid']
      return false if ! @points.include?(message['point'])
      true
    end
  end
end

