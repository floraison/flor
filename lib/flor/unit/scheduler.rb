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
      ) if @conf['domain'] && ! Flor.potential_domain_name?(@conf['domain'])

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

    def identifier

      @identifier ||= 's' + Digest::MD5.hexdigest(self.hash.to_s)[0, 5]
    end

    def shutdown

      @thread_status = :shutdown
      @thread = nil

      @executors.each(&:shutdown)

      @hooker.shutdown
      @storage.shutdown
      @tasker.shutdown
    end

    def hook(*args, &block)

      @hooker.add(*args, &block)
    end

    def on_start_exc(e)

      io = StringIO.new

      head, kind =
        e.is_a?(StandardError) ? [ '=sch', 'error' ] : [ '!sch', 'exception' ]

      t = head[0, 2] + Time.now.to_f.to_s.split('.').last
      io.puts '/' + t + ' ' + head * 17
      io.puts "|#{t} + in #{self.class}#start"
      io.puts "|#{t} db: #{@storage.db.class} #{@storage.db.hash}"
      io.puts "|#{t} thread: #{Thread.current.inspect}"
      io.puts "|#{t} #{kind}: #{e.inspect}"
      io.puts "|#{t} backtrace:"
      e.backtrace.each { |l| io.puts "|#{t} #{l}" }
      io.puts '\\' + t + ' ' + (head * 17) + ' .'

      io.string
    end

    def start

      # TODO heartbeat, every x minutes, when idle, log something

      fail(
        "database not ready, " +
        "db ver: #{@storage.db_version.inspect}, " +
        "mig ver: #{@storage.migration_version}"
      ) unless @storage.ready?

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

              #rescue => er
              rescue Exception => ex

                puts on_start_exc(ex)
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
          [ source_or_path,
            opts[:domain] || df[0],
            df[1] ]
        else
          [ source_or_path,
            opts[:domain] || @conf['domain'] || 'domain0',
            nil ]
        end

      fail ArgumentError.new(
        "invalid domain name #{domain.inspect}"
      ) unless Flor.potential_domain_name?(domain)

      if flow_name

        source = @loader.library(source_or_path)

        # TODO variables
        # TODO payload
      end

      fail ArgumentError.new(
        "flow not found in #{Flor.truncate(source_or_path, 35).inspect}"
      ) unless source

      unit = opts[:unit] || @conf['unit'] || 'u0'

      Flor.print_src(source, opts) if @conf['log_src']

      exid = Flor.generate_exid(domain, unit)
      msg = Flor.make_launch_msg(exid, source, opts)

      return [ msg, opts ] if opts[:nolaunch]
        # for testing purposes

      queue(msg, opts)
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

    def put_timer(message)

      timer = @storage.put_timer(message)

      @mutex.synchronize { @timers.push(timer).sort_by!(&:ntime) }
    end

    def wake_executions(exids)

      @mutex.synchronize { @exids.concat(exids).uniq! } if exids.any?
    end

    def notify(executor, o)

      @hooker.notify(executor, o)

    rescue => err
      puts '-sch' * 19
      puts "+ error in #{self.class}#notify"
      p err
      puts err.backtrace
      puts ('-sch' * 19) + ' .'
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

      return [] if @thread_status != :running
      @storage.load_timers.sort_by(&:ntime)
    end

    def load_exids

      return [] if @thread_status != :running
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

