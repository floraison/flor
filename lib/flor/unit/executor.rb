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
    end

    def run

      messages = unit.storage.fetch_messages(@exid)

      (@unit.conf['exe_max_messages'] || 35).times do |i|

        m = messages.shift
        break unless m

        @unit.log(:pre, m)

        point = m['point']

        p m if point == 'failed'

        break if point == 'failed'
        break if point == 'terminated'

        ms =
          begin
            self.send(point.to_sym, m)
          rescue => e
            error_reply(nil, m, e)
          end

        @unit.log(:post, m)

        messages.concat(ms)
      end

      # TODO: save remaining messages to DB
      # TODO: start work on tasks

      self
    end

    def alive?

      true
    end
  end
end

