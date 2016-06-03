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


class Flor::Pro::Concurrence < Flor::Procedure

  name 'concurrence'

  def pre_execute

    @node['atts'] = {}
  end

  def receive

    cid = Flor.child_id(@message['from'])
    ctree = children[cid]

    return concurrence_execute if ctree[0] == '_att'

    @node['rets'][@message['from']] = @message['payload']

    return [] \
      if @node['rets'].size < children.reject { |c| c[0] == '_att' }.size

    reply
  end

  protected

  def concurrence_execute

    ncid = Flor.child_id(@message['from']) + 1
    nctree = children[ncid]
    return reply unless nctree
    return sequence_receive if nctree[0] == '_att'

    @node['rets'] = {}

    msgs = (ncid..children.size - 1)
      .map { |i| execute_child(i, 0, true) }
      .flatten(1)
    return msgs if msgs.any?

    reply
  end
end

