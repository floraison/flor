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


class Flor::Pro::On < Flor::Procedure

  name 'on'

  def receive_last_att

    fid = @executor.counter_next('funs') - 1
    cid = first_non_att_child_id

    fun =
      [ '_func',
        { 'nid' => nid, 'cnid' => nil, 'fun' => fid, 'cid' => cid },
        tree[2]
      ]
    msg = apply(fun, [], tree[2], false)
      .first
      .merge('noreply' => true, 'from' => parent)
#puts "msg:"
#pp msg

    tra = {}
    tra['bnid'] = parent || '0' # shouldn't it be [the real] root?
    tra['points'] = %w[ signal ]
    tra['tags'] = []
    tra['heaps'] = []
    tra['heats'] = []
    tra['message'] = msg
    tra['count'] = nil       # TODO `on 'xxx' once: true` or `count: 7`
    tra['range'] = 'subnid'  # TODO `on 'xxx' range: 'execution'`
#puts "tra:"
#pp tra

    reply('point' => 'trap','nid' => nid, 'trap' => tra) +
    reply
  end
end

