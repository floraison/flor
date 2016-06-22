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

    def task(tasker_name, fei, payload)

      domain = fei.split('-', 2).first

      tconf =
        @unit.loader.tasker(domain, 'tasker') ||
        @unit.loader.tasker(domain, tasker_name)

      fail ArgumentError.new(
        "tasker #{tasker_name.inspect} not found"
      ) unless tconf

      return ruby_task(
        tasker_name, fei, payload, tconf
      ) if tconf['on_task']['require']

      return cmd_task(
        tasker_name, fei, payload, tconf
      ) if tconf['on_task']['cmd']

      fail ArgumentError.new(
        "don't know how to user tasker at #{tconf['_path']}"
      )
    end

    def cancel(tasker_name, fei)

      # TODO use on_cancel || on_task

      fail NotImplementedError
    end

    def reply(tasker_name, fei, payload)

      exid, nid = Flor.split_fei(fei)

      @unit.queue({
        'point' => 'receive',
        'exid' => exid,
        'nid' => nid,
        'payload' => payload,
        #'from' => nid,
        'tasker_name' => tasker_name })
    end

    protected

    def ruby_task(tname, fei, payload, tconf)

      root = File.dirname(tconf['_path'])

      Array(tconf['on_task']['require'])
        .each { |pa| require(File.join(root, pa)) }

      k = tconf['on_task']['class']
      k = Kernel.const_get(k)

      tasker = k.new(self, tconf)
      tasker.task(tname, fei, payload)
    end

    def cmd_task(tname, fei, payload, tconf)

      fail NotImplementedError
    end
  end
end

