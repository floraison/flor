
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

  class Executor

    def initialize(unit, msgs)

      @unit = unit
      @storage = unit.storage
      @msgs = msgs
    end

    def execute

      exe = @storage.load_execution(@msgs.first['exid'])
      processed = []

      loop do

        # TODO executor is not threaded, so have to break after
        # a certain number of messages

        msg = @msgs.shift
        break unless msg

        case msg['point']
          when 'execute' then handle_execute(exe, msg)
          when 'receive', 'cancel' then handle_receive(exe, msg)
          else handle_event(exe, msg)
        end

        processed.push(msg)
      end

      @storage.flag_as(processed, 'processed')
      @storage.store_back(@msgs)
    end

    protected

    def handle_execute(execution, msg)

      # TODO rewrite tree
      t = msg['tree']

      Flor::Instructions.send("exe_#{t.first}", execution, msg)
    end

    def handle_receive(execution, msg)

      # TODO

      puts "=== receive"
      p msg
      puts "=== receive."
    end
  end
end

