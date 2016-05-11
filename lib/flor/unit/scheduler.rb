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
    attr_reader :logger, :storage

    def initialize(conf={})

      @conf = conf.is_a?(Hash) ? conf : Flor::Conf.read(conf)
      @env = @conf['env'] ||= 'dev'

      @logger = Flor::Logger.new(self)
      @storage = Flor::Storage.new(self)

      @reload_frequency = @conf[:sch_reload_frequency] || 60
      @max_executors = @conf[:sch_max_executors] || 1

      @reloaded_at = nil
      @timers = []
      @exids = []

      @executors = []
    end

    def start

      # TODO heartbeat, every x minutes, when idle, log something

      @thread ||=
        Thread.new do

          loop do

            reload
            trigger_timers
            trigger_executions
          end
        end

      self
    end

    def stop

      @thread.kill if @thread
      @thread = nil
    end

    def running?; !! (@thread && @thread.alive?); end
    def stopped?; @thread.nil?; end

    def join

      @thread.join
    end

    def shutdown

      @logger.shutdown
      @storage.shutdown
    end

    def launch(tree, opts={})

      exid = Flor.generate_exid(
        opts[:domain] || @conf[:domain] || 'domain0',
        opts[:unit] || @conf[:unit] || 'u0')

      m = Flor.make_launch_msg(exid, tree, opts)

      w = opts[:wait] ? @logger.wait(exid, 'terminated') : nil

      @storage.put_message(m)

      w ? w.pop : exid
    end

    protected

    def reload

      now = Time.now

      return if @reloaded_at && (now - @reloaded_at < @reload_frequency)

      @reloaded_at = now
      @timers = load_timers
      @exids = load_exids
    end

    def load_timers

      @storage.load_timers.sort_by { |t| t[:id] }
        # FIXME
    end

    def load_exids

      @storage.load_exids
    end

    def trigger_timers

      now = Time.now

      loop do

        timer = @timers.first
        break if timer == nil || timer.at > now

        trigger_timer(@timers.shift)
      end
    end

    def trigger_executions

      return if @exids.empty?

      @executors = @executors.select { |e| e.alive? }

      @exids.each do |fei|
        break if @executors.size > @max_executors
        @executors << VanillaExecutor.new(self, fei).run
      end
    end
  end
end

