#--
# Copyright (c) 2015-2017, John Mettraux, jmettraux+flor@gmail.com
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

  class BasicTasker

    attr_reader :ganger, :conf, :message

    def initialize(ganger, conf, message)

      @ganger = ganger
      @conf = conf
      @message = message
    end

    protected

    def reply(force=false)

      @ganger.reply(@message) if force || @ganger
    end

    def exid; @message['exid']; end
    def nid; @message['nid']; end

    def execution

      @ganger.unit.execution(exid)
    end

    # For domain taskers
    #
    def route(name)

      if name == false

        [
          Flor.dup_and_merge(
            @message,
            'routed' => false)
        ]

      else

        [
          Flor.dup_and_merge(
            @message,
            'tasker' => name, 'original_tasker' => @message['tasker'],
            'routed' => true)
        ]
      end
    end
  end
end

