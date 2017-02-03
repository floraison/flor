#--
# Copyright (c) 2015-2017, John Mettraux, jmettraux+flor@gmail.com
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

      attr_accessor :conf, :opts
      attr_reader :journal, :ganger, :loader
      attr_accessor :archive

      def initialize(conf)

        @conf = conf
        @opts = {}
        @journal = []
        @archive = nil
      end

      def notify(executor, o)

        return [] if o['consumed']

        Flor.log_message(executor, o) \
          if @conf['log_msg']

        @journal << o

        []
      end

      def remove_node(exid, n)

        (@archive[exid] ||= {})[n['nid']] = Flor.dup(n) if @archive
      end

      def has_tasker?(exid, tname)

        false
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
          #'ashes' => {},
          'start' => Flor.tstamp
        })
    end

    def journal; @unit.journal; end
    def archive; @unit.archive[exid]; end

    def launch(tree, opts={})

      @unit.opts = opts
      @unit.archive = {} if opts[:archive]

      Flor.print_src(tree, opts) if conf['log_src']

      messages = [ Flor.make_launch_msg(@execution['exid'], tree, opts) ]

      Flor.print_tree(messages.first['tree']) if conf['log_tree']

      walk(messages, opts)
    end

    def walk(messages, opts={})

      loop do

        message = messages.shift
        return nil unless message

        if message['point'] == 'terminated' && messages.any?
          #
          # try to handle 'terminated' last
          #
          messages << message
          message = messages.shift
        end

        msgs = process(message)

        messages.concat(msgs)

        return messages if message_match?(message, opts[:until_after])
        return messages if message_match?(messages, opts[:until])

        return message \
          if message['point'] == 'terminated'
        return message \
          if message['point'] == 'failed' && message['on_error'] == nil
      end
    end

    def step(message)

      process(message)
    end

    # Used in specs when testing multiple message arrival order on
    # a "suite" of transient executors
    #
    def clone

      c = TransientExecutor.allocate

      c.instance_variable_set(:@unit, @unit)
      c.instance_variable_set(:@traps, []) # not useful for a TransientEx clone
      c.instance_variable_set(:@execution, Flor.dup(@execution))

      c
    end

    protected

    # TODO eventually merge with Waiter.parse_serie
    #
    def message_match?(msg_s, ountil)

      return false unless ountil

      ms = msg_s; ms = [ ms ] if ms.is_a?(Hash)

      nid, point = ountil.split(' ')

      ms.find { |m| m['nid'] == nid && m['point'] == point }
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

      vs['root'] = determine_root(path)

      vs['ruby_version'] = RUBY_VERSION
      vs['ruby_platform'] = RUBY_PLATFORM

      c = (ENV['FLOR_DEBUG'] || '').match(/conf/) ? false : true
      r = (self.new('conf' => c)).launch(s, vars: vs)

      unless r['point'] == 'terminated'
        ae = ArgumentError.new("error while reading conf: #{r['error']['msg']}")
        ae.set_backtrace(r['error']['trc'])
        fail ae
      end

      h = Flor.dup(r['payload']['ret'])

      h.merge!('_path' => path) unless path.match(/[\r\n]/)

      h
    end

    def self.determine_root(path)

      dir = File.absolute_path(File.dirname(path))
      ps = dir.split(File::SEPARATOR)

      ps.last == 'etc' ? File.absolute_path(File.join(dir, '..')) : dir
    end
  end
end

