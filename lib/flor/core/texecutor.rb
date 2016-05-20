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

    class TransientStorage

      def remove_node(exid, n); end
    end

    class TransientUnit

      attr_reader :storage
      attr_accessor :conf

      def initialize(conf)

        @conf = conf
        @storage = TransientStorage.new
      end

      def notify(o)

        return unless o.is_a?(Hash)
        return unless @conf['log_msg']
        return if o['consumed']

        Flor.log_message(message)
      end
    end

    def initialize(conf={})

      conf.merge!(Flor::Conf.read_env) unless conf['conf'] == true
        # don't read FLOR_DEBUG if this executor is only meant to read the conf

      super(
        TransientUnit.new(conf),
        [], # no traps
        {
          'exid' => Flor.generate_exid('eval', 'u0'),
          'nodes' => {}, 'errors' => [], 'counters' => {},
          'start' => Flor.tstamp
        })
    end

    def launch(tree, opts={})

      messages = [ Flor.make_launch_msg(@execution['exid'], tree, opts) ]
      message = nil

      Flor.print_src(tree) if conf['log_src']
      Flor.print_tree(messages.first['tree']) if conf['log_tree']

      loop do

        message = messages.pop

        break unless message

        @unit.notify(message)

        point = message['point']

        pp message if point == 'failed' && conf['log_err']

        break if point == 'failed'
        break if point == 'terminated'

        msgs = process(message)

        messages.concat(msgs)
      end

      message
    end
  end
end

