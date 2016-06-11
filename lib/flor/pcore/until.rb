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


class Flor::Pro::Until < Flor::Procedure

  names 'until', 'while'

  def pre_execute

    @node['count'] = 0
  end

  def post_att_receive

    return execute_child(first_unkeyed_child, @node['count'] += 1) \
      if @message['point'] == 'execute'

    #@node['mtime'] = Flor.tstamp

    func = first_unkeyed_child
    fcid = Flor.child_id(from)

    if fcid == func # from condition

      t0 = tree[0]
      tru = Flor.true?(payload['ret'])
      if (tru && t0 == 'until') || ( ! tru && t0 == 'while')
        payload['ret'] = @node['ret'] if @node.has_key?('ret')
        reply
      else
        execute_child(func + 1, @node['count'])
      end

    elsif fcid == children.size - 1 # from last child

      @node['ret'] = Flor.dup(payload['ret'])
      execute_child(func, @node['count'] += 1)

    else # from a child in the middle

      @node['ret'] = Flor.dup(payload['ret'])
      execute_child(fcid + 1, @node['count'])
    end
  end
end

