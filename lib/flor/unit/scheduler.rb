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
    attr_reader :logger, :storage, :loader, :tasker

    attr_reader :thread_status

    def initialize(conf={}, over_conf={})

      @conf = conf.is_a?(Hash) ? conf : Flor::Conf.read(conf)
      @conf.merge!(Flor::Conf.read_env)
      @conf.merge!(over_conf)

      @env = @conf['env'] ||= 'dev'

      @logger =
        (Flor::Conf.get_class(@conf, 'logger') || Flor::Logger).new(self)
      @storage =
        (Flor::Conf.get_class(@conf, 'storage') || Flor::Storage).new(self)
      @loader =
        (Flor::Conf.get_class(@conf, 'loader') || Flor::Loader).new(self)
      @tasker =
        (Flor::Conf.get_class(@conf, 'tasker') || Flor::Tasker).new(self)

      @heart_rate = @conf[:sch_heart_rate] || 0.3
      @reload_frequency = @conf[:sch_reload_frequency] || 60
      @max_executors = @conf[:sch_max_executors] || 1

      @mutex = Mutex.new

      @reloaded_at = nil
      @timers = []
      @exids = []

      @executors = []
      @waiters = []
    end

    def shutdown

      @thread_status = :shutdown
      @thread = nil

      @logger.shutdown
      @storage.shutdown
      @tasker.shutdown
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
puts e.backtrace
puts ('=' * 80) + ' .'
              rescue Exception => ex
puts '!' * 80
p ex
puts e.backtrace
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

    def launch(tree, opts={})

      Flor.print_src(tree, opts) if @conf['log_src']

      exid = Flor.generate_exid(
        opts[:domain] || @conf['domain'] || 'domain0',
        opts[:unit] || @conf['unit'] || 'u0')

      queue(Flor.make_launch_msg(exid, tree, opts), opts)
    end

    def queue(message, opts={})

      @storage.put_message(message)

      if ow = opts[:wait]
        wait(message['exid'], ow)
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

    def notify(o)

      case o
        when Array # list of exids
          @mutex.synchronize { @exids.concat(o).uniq! } if o.any?
        when Timer
          @mutex.synchronize { @timers.push(o); @timers.sort_by!(&:ntime) }
        when Hash
          if o['consumed']
            notify_waiters(o)
          else
            (@journal ||= []) << o if @conf['journal']
            @logger.notify(o)
          end
        else
          fail ArgumentError.new(
            "don't know what to do with a #{o.class} instance")
      end
    end

    def trap(node, tra, msg)

      @storage.put_trap(node, tra, msg)
    end

    def remove_node(exid, n)

      @storage.remove_node(exid, n)

      @mutex.synchronize do
        @timers.reject! { |t| t.exid == exid && t.nid == n['nid'] }
      end
    end

    def journal

      @journal
    end

    protected

    def notify_waiters(message)

      @mutex.synchronize do

        to_remove = []

        @waiters.each do |w|
          remove = w.notify(message)
          to_remove << w if remove
        end

        @waiters -= to_remove
      end
    end

    def wait(exid, owait)

      w = nil

      serie, timeout, repeat = [
        [ [ nil, %w[ failed terminated ] ] ],
        owait,
        false ]

      @mutex.synchronize do

        @waiters << (w = Waiter.new(exid, serie, timeout, repeat))
      end

      w.wait
    end

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
        break if timer == nil || timer.ntime > now

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

