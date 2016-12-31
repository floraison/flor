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


class Flor::Pro::Happly < Flor::Procedure

  name '_happly'

  def pre_execute

    @node['atts'] = []
  end

  def execute

    queue(
      'point' => 'execute',
      'nid' => Flor.child_nid(nid, tree[1].size),
      'tree' => tree[0])
  end

  def receive

    fcid = Flor.child_id(message['from'])

    return reply if @node['applied']
    return super unless fcid == tree[1].size

    ret = payload['ret']

    @node['hret'] = payload['ret']
    execute_child(0)
  end

  def receive_last

    hret = @node['hret']

    return reply('ret' => hret) unless Flor.is_func_tree?(hret)

    args = @node['atts'].collect(&:last)

    hret[1].merge!('head' => true, 'nid' => nid)

    msgs = apply(hret, args, tree[2])

    @node['applied'] = msgs.first['nid']

    msgs
  end
end

