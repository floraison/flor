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

  class Scheduler

    attr_reader :conf, :env
    attr_reader :hooker, :storage, :loader, :tasker

    attr_reader :thread_status

    def initialize(conf={}, over_conf={})

      @conf = conf.is_a?(Hash) ? conf : Flor::Conf.read(conf)
      @conf.merge!(Flor::Conf.read_env)
      @conf.merge!(over_conf)

      fail ArgumentError.new(
        "invalid domain name #{@conf['domain']}"
      ) unless Flor.potential_domain_name?(@conf['domain'])

      @env = @conf['env'] ||= 'dev'

      @hooker =
        (Flor::Conf.get_class(@conf, 'hooker') || Flor::Hooker).new(self)
      @storage =
        (Flor::Conf.get_class(@conf, 'storage') || Flor::Storage).new(self)
      @loader =
        (Flor::Conf.get_class(@conf, 'loader') || Flor::Loader).new(self)
      @tasker =
        (Flor::Conf.get_class(@conf, 'tasker') || Flor::Tasker).new(self)

      @hooker.add('logger', Flor::Logger)
      @hooker.add('wlist', Flor::WaitList)

      @heart_rate = @conf[:sch_heart_rate] || 0.3
      @reload_frequency = @conf[:sch_reload_frequency] || 60
      @max_executors = @conf[:sch_max_executors] || 1

      @mutex = Mutex.new

      @reloaded_at = nil
      @timers = []
      @exids = []

      @executors = []
    end

    def shutdown

      @thread_status = :shutdown
      @thread = nil

      @hooker.shutdown
      @storage.shutdown
      @tasker.shutdown
    end

    def hook(*args, &block)

      @hooker.add(*args, &block)
    end

    def start

      # TODO heartbeat, every x minutes, when idle, log something

      @thread_status = :running

      @thread =
        if @thread

          @thread.run

        else

          Thread.new do
            loop do

              begin

                t0 = Time.now

                Thread.stop if @thread_status == :stop
                break if @thread_status == :shutdown

                reload
                trigger_timers
                trigger_executions

                sleep [ @heart_rate - (Time.now - t0), 0 ].max

# TODO FIXME
              rescue => re
puts '=' * 80
p re
puts re.backtrace
puts ('=' * 80) + ' .'
              rescue Exception => ex
puts '!' * 80
p ex
puts ex.backtrace
puts ('!' * 80) + ' .'
              end
            end
          end
        end

      self
    end

    def stop

      @thread_status = :stop
    end

    def running?; @thread_status == :running; end
    def stopped?; ! running?; end

    def join

      @thread.join
    end

    def launch(source_or_path, opts={})

      source, domain, flow_name =
        if df = Flor.split_flow_name(source_or_path)
          [ source_or_path, df[0], df[1] ]
        else
          [ source_or_path, @conf['domain'] || 'domain0', nil ]
        end

      if flow_name
        source = @loader.library(source_or_path)
        # TODO variables
        # TODO payload
      end

      unit = opts[:unit] || @conf['unit'] || 'u0'

      Flor.print_src(source, opts) if @conf['log_src']

      exid = Flor.generate_exid(domain, unit)
      msg = Flor.make_launch_msg(exid, source, opts)

      return [ msg, opts ] if opts[:nolaunch]
        # for testing purposes

      queue(msg, opts)

#      domain, flow, tree =
#        if Flor.potential_domain_name?(tree_or_path)
#          es = tree_or_path.split('.')
#          t = @loader.library(tree_or_path)
#          [ es[0..-2].join('.'), es[-1], t ]
#        else
#          [ nil, nil, tree_or_path ]
#        end
#
#      opts[:vars] ;;fail
#
#      fail ArgumentError.new(
#        "tree not found from #{Flor.truncate(tree_or_path, 56).inspect}"
#      ) unless tree
#
#      Flor.print_src(tree, opts) if @conf['log_src']
#
#      dom = opts[:domain] || domain || @conf['domain']
#      uni = opts[:unit] || @conf['unit'] || 'u0'
#
#      fail ArgumentError.new(
#        "invalid domain name #{dom.inspect}"
#      ) unless Flor.potential_domain_name?(dom)
#
#      fail ArgumentError.new(
#        "invalid unit name #{uni.inspect}"
#      ) unless Flor.potential_unit_name?(uni)
#
#      exid = Flor.generate_exid(domain, unit)
#      msg = Flor.make_launch_msg(exid, tree, opts)
#
#      return [ msg, opts ] if opts[:nolaunch]
#        # for testing purposes
#
#      queue(msg, opts)
    end

    def queue(message, opts={})

      @storage.put_message(message)

      if opts[:wait]
        wait(message['exid'], opts)
      else
        message['exid']
      end
    end

    def cancel(h)

      msg = { 'point' => 'cancel' }
      msg['exid'] = h[:exid] || fail(ArgumentError.new('missing :exid key'))
      if nid = h[:nid]; msg['nid'] = nid; end

      queue(msg, h)
    end

    def notify(executor, o)

      case o
        when Array # list of exids
          @mutex.synchronize { @exids.concat(o).uniq! } if o.any?
        when Timer
          @mutex.synchronize { @timers.push(o); @timers.sort_by!(&:ntime) }
        when Hash
          @hooker.notify(executor, o)
        else
          fail ArgumentError.new(
            "don't know what to do with a #{o.class} instance")
      end

    rescue => err
      puts 'n' * 80
      puts "error in #{self.class}#notify"
      p err
      puts err.backtrace
      puts ('n' * 80) + ' .'
    end

    def trap(node, tra)

      @storage.put_trap(node, tra)
    end

    def remove_node(exid, n)

      @storage.remove_node(exid, n)

      @mutex.synchronize do
        @timers.reject! { |t| t.exid == exid && t.nid == n['nid'] }
      end
    end

    protected

#    # return [ domain, tree ]
#    #
#    def extract_domain_and_tree(s, opts)
#
#      if Flor.potential_domain_name?(s)
#
#        path = [ opts[:domain], s ].compact.join('.')
#        elts = path.split('.')
#        flow = @loader.library(path)
#
#        fail ArgumentError.new(
#          "flow not found at #{path.inspect}"
#        ) unless flow
#
#        [ elts[0..-2].join('.'), flow ]
#
#      else
#
#        [ opts[:domain], s ]
#      end
#    end

    def reload

      now = Time.now

      return if @reloaded_at && (now - @reloaded_at < @reload_frequency)

      @mutex.synchronize do

        @reloaded_at = now
        @timers = load_timers
        @exids = load_exids
      end
    end

    def load_timers

      @storage.load_timers.sort_by(&:ntime)
    end

    def load_exids

      @storage.load_exids
    end

    def trigger_timers

      now = Time.now

      loop do

        timer = @timers.first
        break if timer == nil || timer.ntime_t > now

        @storage.trigger_timer(@timers.shift)
      end
    end

    def trigger_executions

      return if @exids.empty?

      while exid = @mutex.synchronize { @exids.shift }

        @executors = @executors.select { |e| e.alive? }
          # drop done executors

        break if @executors.size > @max_executors
        next if @executors.find { |e| e.exid == exid }

        @executors << UnitExecutor.new(self, exid).run
      end
    end
  end
end

