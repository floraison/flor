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


class Flor::Pro::Apply < Flor::Procedure

  name 'apply'

  def heat=(t); @heat = t; end

  def execute

    args = attributes.dup

    @heat ||= lookup(args.delete('_0'))

    ni = @heat[1]['v']['nid']
    #vni = @applied[1]['v']['vnid'] # closure...

    tree = lookup_tree_anyway(ni)
    sig = tree[1]
    off = tree[0] == 'def' ? 0 : 1
    vars = {}

    args.each_with_index { |(k, v), i|
      #p [ k, v, i, '-->', "_#{i + off}", sig["_#{i + off}"] ]
      vars[sig["_#{i + off}"]] = v
    }
    #p vars

    reply(
      'point' => 'execute',
      'nid' => "#{ni}-#{sub_counter_next}",
      'tree' => [ 'sequence', {}, *tree[2..4] ],
      'vars' => vars)
  end

  def receive

    reply
  end
end

