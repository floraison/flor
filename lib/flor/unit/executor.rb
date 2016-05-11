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

  class UnitExecutor < Flor::Executor

    attr_reader :exid

    def initialize(unit, exid)

      super(unit)

      @exid = exid
      @messages = unit.storage.fetch_messages(exid)
      @consumed = []
      @alive = true
    end

    def alive?; @alive; end

    def run

      Thread.new { do_run }

      self
    end

    protected

    def do_run

      (@unit.conf['exe_max_messages'] || 35).times do |i|

        m = @messages.shift
        break unless m

        @unit.log(:pre, m)

        point = m['point']

        ms = process(m)

        @consumed << m

        @unit.log(:post, m)

        @messages.concat(ms)
      end

      flag_consumed

      @alive = false
        # TODO

      # TODO: save remaining messages to DB
      # TODO: start work on tasks

    rescue => e
puts "=" * 80
p e
puts e.backtrace[0, 7]
puts ("=" * 80) + ' .'
    end

    def failed(message)

puts " *** failed: " + message.inspect

      []
    end

    def flag_consumed

      @unit.storage.consume(@consumed)
    end
  end
end

