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

    class TransientTasker

      def has_tasker?(exid, tname); false; end
    end

    class TransientUnit

      attr_accessor :conf, :opts
      attr_reader :journal, :tasker

      def initialize(conf)

        @conf = conf
        @opts = {}
        @journal = []
        @tasker = TransientTasker.new
      end

      def notify(executor, o)

        return unless o.is_a?(Hash)
        return if o['consumed']

        if o['point'] == 'execute' && o['nid'] == '0'
          Flor.print_tree(o['tree']) if conf['log_tree']
        end

        Flor.log_message(executor, o) if @conf['log_msg']

        @journal << o
      end

      def remove_node(exid, n)

        # nothing to do
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
          'nodes' => {}, 'errors' => [], 'counters' => {}, 'ashes' => {},
          'start' => Flor.tstamp
        })
    end

    def journal

      @unit.journal
    end

    def launch(tree, opts={})

      @unit.opts = opts

      Flor.print_src(tree, opts) if conf['log_src']

      messages = [ Flor.make_launch_msg(@execution['exid'], tree, opts) ]
      message = nil

      loop do

        message = messages.shift
        break unless message

        if message['point'] == 'terminated' && messages.any?
          #
          # try to handle 'terminated' last
          #
          messages << message
          message = messages.shift
        end

        msgs = process(message)

        break if %w[ failed terminated ].include?(message['point'])

        messages.concat(msgs)
      end

      message ? unash_all!(message) : nil
    end
  end

  class ConfExecutor < TransientExecutor

    def self.interpret(path)

      s = path

      s = File.read(s).strip unless s.match(/[\r\n]/)
      s = "{\n#{s}\n}"

      vs = Hash.new { |h, k| k }
      class << vs
        def has_key?(k); ! Flor::Procedure[k]; end
      end

      vs['ruby_version'] = RUBY_VERSION
      vs['ruby_platform'] = RUBY_PLATFORM

      c = (ENV['FLOR_DEBUG'] || '').match(/conf/) ? false : true
      r = (self.new('conf' => c)).launch(s, vars: vs)

      fail ArgumentError.new(
        "error while reading conf: #{r['error']['msg']}"
      ) unless r['point'] == 'terminated'

      h = Flor.dup(r['payload']['ret'])

      h.merge!('_path' => path) unless path.match(/[\r\n]/)

      h
    end
  end
end

