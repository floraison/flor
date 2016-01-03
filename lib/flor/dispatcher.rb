
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

    def initialize(unit)

      @unit = unit

      @schedules = @unit.list_schedules
      @status = :loading
      @thread = Thread.new { run }
    end

    def run

      loop do

        break if @status == :stopping

        msgs =
          schedules_to_trigger +
          @unit.list_dispatcher_messages

        msgs.group_by(&:exid).values.each { |ms| dispatch(ms) }

        sleep(msgs.length > 0 ? 0.001 : 0.490)
      end

    rescue => err

      print_error(err)
    end

    def stop

      @status = :stopping
    end

    def touch

      return if @status == :stopping
      @status = :loading
    end

    protected

    def schedules_to_trigger

      [] # TODO
    end

    def dispatch(msgs)

      schs = []
      exes = []
      tsks = []

      msgs.each do |msg|

        if msg.point == 'task'
          tsks << msg
        elsif msg.point.match(/schedule\z/)
          schs << msg
        else
          exes << msg
        end
      end

      schedule(schs)
      execute(exes)
      task(tsks)

    rescue => err

      print_error(err)
    end

    def print_error(err)

      puts "=== #{self.class}"
      p err
      puts err.backtrace
      puts "=== #{self.class} ."
    end

    def schedule(msgs)

      # TODO
    end

    def execute(msgs)

      Flor::Executor.new(@unit, msgs).execute
    end

    def task(msgs)

      # TODO
    end
  end
end

