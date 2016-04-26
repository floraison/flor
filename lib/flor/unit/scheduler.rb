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

      @messages = []
      @timers = []

      #@frequency = conf[:frequency] || 0.3
      @thread = nil
    end

    def start

      # TODO heartbeat, every x minutes, when idle, log something
      # TODO once per minute, querying flor_messages for incoming messages

      @thread ||=
        Thread.new do

          load_timers
          last_min = -1

          loop do
            begin
              sleep(0.3)
puts "... #{Time.now} (#{last_min})"
              if (min = Time.now.min) != last_min
                last_min = min
                process_messages
              end
              process_timers
            rescue => e
              @logger.error('ouch!', e)
            end
          end
        end

      self
    end

    def poke

      # TODO forces scheduler to look at DB for incoming messages
      # TODO should it check the thread? It might have died...
    end

    def stop

      @thread.kill if @thread
      @thread = nil
    end

    def running?; @thread && @thread.alive?; end
    def stopped?; @thread.nil?; end

    def join

      @thread.join
    end

    protected

    def process_messages

      # load messages from db and process if any

      ms = @storage.fetch_messages

      ms = ms.inject({}) { |h, m| (h[m['fei']] ||= []) << m; h }

      ms.values.each { |ms| VanillaExecutor.new(self, ms).run }
    end

    def load_timers

      @storage.fetch_timers.each do |t|

        # turn timers as stored in db to the timers used here
        # store in good order (early first)
      end
    end

    def process_timers

      now = Time.now

      loop do
        timer = @timers.first
        break if timer == nil || timer.at > now
        trigger_timer(@timers.shift)
      end
    end
  end
end

