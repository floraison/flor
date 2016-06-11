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


class Flor::Pro::Cond < Flor::Procedure

  name 'cond'

  def pre_execute

    @node['ret'] = Flor.dup(payload['ret'])
  end

  def post_att_receive

    return execute_child(0) if @message['point'] == 'execute'
    return reply if @node['found']

    f = Flor.child_id(from)
    tf2 = tree[1][f + 2]

    if Flor.true?(payload['ret'])
      @node['found'] = true
      execute_child(f + 1)
    elsif tf2 && tf2[0, 2] == [ 'else', [] ]
      @node['found'] = true
      execute_child(f + 3)
    else
      execute_child(f + 2)
    end
  end

  protected

  def execute_child(i)

    payload['ret'] = @node['ret'] unless tree[1][i]

    super(i)
  end
end

