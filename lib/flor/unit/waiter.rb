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

  class Waiter

    DEFAULT_TIMEOUT = 4 # seconds

    def initialize(exid, serie, timeout, repeat)

      @exid = exid
      @original_serie = repeat ? Flor.dup(serie) : nil
      @serie = serie
      @timeout = timeout == true ? DEFAULT_TIMEOUT : timeout

      @queue = []
      @mutex = Mutex.new
      @var = ConditionVariable.new
    end

    def to_s

      "#{super[0..-2]}#{
        { exid: @exid,
          original_serie: @original_serie,
          timeout: @timeout }.inspect
      }>"
    end

    def self.make(exid, opts)

      owait = opts[:wait]

      serie, timeout, repeat =
        if owait == true
          [ [ [ nil, %w[ failed terminated ] ] ], # serie
            DEFAULT_TIMEOUT,
            false ] # repeat
        elsif owait.is_a?(Numeric)
          [ [ [ nil, %w[ failed terminated ] ] ], # serie
            owait, # timeout
            false ] # repeat
        elsif owait.is_a?(String) || owait.is_a?(Array)
          [ parse_serie(owait), # serie
            opts[:timeout] || DEFAULT_TIMEOUT,
            false ] # repeat
        elsif owait.is_a?(Hash)
          [ parse_serie(owait[:serie]),
            owait[:timeout],
            owait[:repeat] ]
        end

        Waiter.new(exid, serie, timeout, repeat)
    end

    def notify(executor, message)

      @mutex.synchronize do

        return false unless match?(message)

        @serie.shift
        return false unless @serie.empty?

        @queue << [ executor, message ]
        @var.signal
      end

      # then...
      # returning false: do not remove me, I want to listen/wait further
      # returning true: remove me

      return true unless @original_serie

      @serie = Flor.dup(@original_serie) # reset serie

      false # do not remove me
    end

    def wait

      @mutex.synchronize do

        if @queue.empty?

          @var.wait(@mutex, @timeout)
            # will wait "in aeternum" if @timeout is nil

          fail(RuntimeError, "timeout for #{self.to_s}") if @queue.empty?
        end

        executor, message = @queue.shift

        message
      end
    end

    protected

    def match?(message)

      return false if @exid && @exid != message['exid']

      nid, points = @serie.first
      return false if nid && message['nid'] && ! nid.match(message['nid'])
      return false if ! points.include?(message['point'])

      true
    end

    def self.parse_serie(s)

      return s if s.is_a?(Array) && s.collect(&:class).uniq == [ Array ]

      (s.is_a?(String) ? s.split(',') : s)
        .map { |s|
          s
            .match(/\A *([0-9_\-]+ )?([a-z]+) *\z/)[1, 2]
            .collect { |s| s ? s.strip : nil }
        }
    end
  end
end

