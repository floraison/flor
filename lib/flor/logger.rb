
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

    @callbacks = []
    @mutex = Mutex.new
  end

  def log(msg)

    @mutex.synchronize do

      @callbacks = @callbacks.reject(&:consumed)
      @callbacks.each { |cb| cb.feed(msg) }
    end
  end

  def wait(exid, point_s, nid, maxsec)

    w = WaitCallback.new(exid, point_s, nid, maxsec)

    @mutex.synchronize { @callbacks << w }

    w.activate
  end

  def on(exid, point_s, nid, &block)

    @mutex.synchronize do

      @callbacks << OnCallback.new(exid, point_s, nid, block).activate
    end
  end

  class Callback

    attr_reader :consumed

    def initialize(exid, point_s, nid)

      @exid = exid
      @points = point_s ? Array(point_s).collect(&:to_s) : nil
      @nid = nid

      @consumed = false
    end

    def match(msg)

      return false if @exid && @exid != msg['exid']
      return false if @points && ! @points.include?(msg['point'])
      return false if @nid && @nid != msg['nid']
      true
    end

    def feed(msg)

      trigger(msg) if match(msg)
    end

    def activate

      self
    end
  end

  class OnCallback < Callback

    def initialize(exid, point_s, nid, block)

      super(exid, point_s, nid)
      @block = block
    end

    def trigger(msg)

      @block.call(msg)
    end
  end

  class WaitCallback < Callback

    def initialize(exid, point_s, nid, maxsec)

      super(exid, point_s, nid)
      @maxsec = maxsec

      @queue = Queue.new
    end

    def trigger(msg)

      @consumed = true
      @queue << msg
    end

    def activate

      Thread.new do
        sleep @maxsec
        @queue << :timed_out
      end if @maxsec > 0

      @queue.pop
    end
  end
end

