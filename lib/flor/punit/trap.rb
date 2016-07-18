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


class Flor::Pro::Trap < Flor::Procedure

  name 'trap'

  def pre_execute

#    fail ArgumentError.new(
#      "trap requires at least one 'point' attribute"
#    ) if att_children.size < 1
#    fail ArgumentError.new(
#      "trap requires at least one child node"
#    ) if non_att_children.size < 1
#
#    @node['atts'] = []
#      # so that atts get collected

    @node['vars'] = {}
    @node['atts'] = []
    @node['fun'] = nil

    #unatt_unkeyed_children
  end

  def receive_non_att

    return execute_child(@ncid) if children[@ncid]

    fun = payload['ret']

    fail ArgumentError.new(
      'trap requires a function'
    ) unless Flor.is_func?(fun)

    points = att_a('point', 'points', nil)
    tags = att_a('tag', 'tags', nil)
    nids = att_a('nid', 'nids', nil)

    points = att_a(nil, nil) unless points || tags || nids
    points = [ 'entered' ] if tags && ! nids && ! points

#    msg = {
#      'point' => 'execute',
#      'tree' => children[1],  # FIXME might not be child 1
#      'nid' => "#{nid}_1",    # FIXME might not be child 1
#      'exid' => exid,
#      'payload' => @message['payload'],
#      'from' => nid
#    }
    msg = apply(fun, [], tree[2], false).first
    msg['noreply'] = true

    tra = { 'points' => points, 'tags' => tags, 'nids' => nids }
    tra['message'] = msg

    reply('point' => 'trap','nid' => nid, 'trap' => tra) +
    reply
  end

  def receive_last

    fail ArgumentError.new('trap requires a function')
  end
end

