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

  class Tasker

    # NB: tasker configuration entries start with "tsk_"

    def initialize(unit)

      @unit = unit
    end

    def shutdown
    end

    def task(message)

      domain = message['exid'].split('-', 2).first
      tname = message['tasker']

      tconf =
        @unit.loader.tasker(domain, 'tasker') ||
        @unit.loader.tasker(domain, message['tasker'])
          #
          # FIXME tasker tasker tasker lookup loop?

      fail ArgumentError.new(
        "tasker #{tname.inspect} not found"
      ) unless tconf

      message['tconf'] = tconf \
        unless tconf['on_task']['include_tconf'] == false

      return ruby_task(message, tconf) if tconf['on_task']['require']
      return cmd_task(message, tconf) if tconf['on_task']['cmd']

      fail ArgumentError.new(
        "don't know how to user tasker at #{tconf['_path']}"
      )
    end

    def cancel(tasker_name, fei)

      # TODO use on_cancel || on_task

      fail NotImplementedError
    end

    def reply(message)

      @unit.queue({
        'point' => 'return',
        'exid' => message['exid'],
        'nid' => message['nid'],
        'payload' => message['payload'],
        'tasker' => message['tasker'] })
    end

    protected

    def ruby_task(message, tconf)

      root = File.dirname(tconf['_path'])

      Array(tconf['on_task']['require'])
        .each { |pa| require(File.join(root, pa)) }
# TODO 'load' too

      k = tconf['on_task']['class']
      k = Kernel.const_get(k)

      tasker = k.new(self, tconf)
      tasker.task(message)

      []
    end

    def cmd_task(message, tconf)

      fail NotImplementedError

      []
    end
  end
end

