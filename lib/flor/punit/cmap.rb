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

require 'flor/punit/concurrence'
  # because "cmap" > "concurrence" and we need our parent class


class Flor::Pro::Cmap < Flor::Pro::Concurrence

  name 'cmap'

  def receive_last_att

    return reply unless children[@ncid]

pp @node['atts']
    col = att(nil)

    col
      .map { |i|
        execute_child(
          0, counter_next('subs'), 'payload' => payload.copy_current) }
      .flatten(1)
      .tap { |x| pp x }
        #
        # call execute for each of the (non _att) children
  end
end

