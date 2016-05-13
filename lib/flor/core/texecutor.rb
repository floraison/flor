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

  class TransientExecutor < Executor

    class TransientUnit

      attr_accessor :conf

      def initialize(conf)

        @conf = conf
      end

      def log(pos, message)

        Flor.log(message) if pos == :pre && @conf[:log]
      end
    end

    def initialize(conf={})

      h =
        (ENV['FLOR_DEBUG'] || '').split(',').inject({}) { |h, k|
          kv = k.split(':')
          h[kv[0].to_sym] = kv[1] ? JSON.parse(kv[1]) : true
          h
        }
      h.merge!({ err: 1, log: 1, tree: 1, src: 1 }) if h[:all]
      h.merge!(conf)
        #
        # TODO eventually prefix err, log, tree and src...

      super(
        TransientUnit.new(h),
        {
          'exid' => Flor.generate_exid('eval', 'u0'),
          'nodes' => {}, 'errors' => [], 'counters' => {},
          'start' => Flor.tstamp
        })
    end

    def launch(tree, opts={})

      messages = [ Flor.make_launch_msg(@execution['exid'], tree, opts) ]
      message = nil

      Flor.print_src(tree) if conf[:src]
      Flor.print_tree(messages.first['tree']) if conf[:tree]

      loop do

        message = messages.pop

        break unless message

        @unit.log(:pre, message)

        point = message['point']

        pp message if point == 'failed' && conf[:err]

        break if point == 'failed'
        break if point == 'terminated'

        msgs = process(message)

        @unit.log(:post, message)

        messages.concat(msgs)
      end

      message
    end
  end
end

