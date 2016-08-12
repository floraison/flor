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

    @node['vars'] = {}
    @node['atts'] = []
    @node['fun'] = nil

    #unatt_unkeyed_children
  end

  def receive_non_att

    return execute_child(@ncid) if children[@ncid]

    fun = @fcid > 0 ? payload['ret'] : nil

    points = att_a('point', 'points', nil)
    tags = att_a('tag', 'tags', nil)
    nids = att_a('nid', 'nids', nil)
    heats = att_a('heat', 'heats', nil)
    heaps = att_a('heap', 'heaps', nil)

    points = att_a(nil, nil) unless points || tags || nids
    points = [ 'entered' ] if tags && ! nids && ! points

    msg =
      if fun
        apply(fun, [], tree[2], false).first.merge('noreply' => true)
      else
        reply.first
      end

    tra = {
      'points' => points, 'tags' => tags, 'nids' => nids,
      'heaps' => heaps, 'heats' => heats
    }
    tra['message'] = msg

    count = att('count')
    count = 1 if fun == nil # blocking mode implies count: 1
    tra['count'] = count if count

    exi = att('exid') || att('execution') || exid
    tra['exid'] = exi if exi != 'any'

    reply('point' => 'trap','nid' => nid, 'trap' => tra) +
    (fun ? reply : [])
  end

  def receive_last

    #fail ArgumentError.new('trap requires a function')
    receive_non_att
  end
end

