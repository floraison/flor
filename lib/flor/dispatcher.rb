
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

  class Dispatcher

    def initialize

      @schedules = Flor::Db::Schedules.list
      @status = :loading
      @thread = Thread.new { run }
    end

    def run

      loop do

        break if @status == :stopping

        count = 0

        count += trigger_schedules

        next unless @status == :loading

        @status = :loaded

        Flor::Db::Message.list_for_dispatcher.each do |msgs|
          count += msgs.length
          dispatch(msgs)
        end

        sleep(count > 0 ? 0.001 : 0.490)
      end
    end

    def stop

      @status = :stopping
    end

    def touch

      return if @status == :stopping
      @status = :loading
    end

    protected

    def dispatch(msgs)

      return if msgs.empty?

      case msg.point
        when 'schedule' then schedule(msgs)
        #when 'execute', 'return', 'receive' then execute(msgs)
        else execute(msgs)
      end

      if msgs.first.point == 'schedule'
        schedule(msgs)
      else
        execute(msgs)
      end

    rescue => err

      puts "=== dispatcher encountered issue"
      p err
      puts err.backtrace
      puts "=== ."
    end
  end
end

