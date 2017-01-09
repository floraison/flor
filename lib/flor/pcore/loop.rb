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


class Flor::Pro::Loop < Flor::Pro::Cursor
  #
  # Executes child expressions in sequence, then loops around.
  #
  # It's mostly a [cursor](cursor.md) that loops upon going past its
  # last child.
  #
  # ```
  # loop
  #   task 'alpha'
  #   task 'bravo'
  # ```
  #
  # Accepts `break` and `continue` like `cursor` does.

  name 'loop'

  def receive_non_att

    if @ncid >= children.size
      @node['subs'] << counter_next('subs')
      execute_child(first_non_att_child_id, @node['subs'].last)
    else
      execute_child(@ncid, @node['subs'].last)
    end
  end
end

