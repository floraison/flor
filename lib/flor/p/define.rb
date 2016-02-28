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


class Flor::Pro::Define < Flor::Procedure

  names 'def', 'define'

  def execute

    tr = tree

    cnode = lookup_var_node('l', @node)
    cnid = cnode['nid']
#p nid
#p cnode
#p cnid

    v = { 'nid' => nid, 'cnid' => cnid, 'fun' => counter_next('fun') }
    as = { 't' => 'function', 'v' => v }
    val = [ 'val', as, tr[2], [], *tr[4] ]

    set_var('l', tr[1]['_0'].to_s, val) if tr[0] == 'define' && tr[1]['_0']
    payload['ret'] = val

    reply
  end
end

