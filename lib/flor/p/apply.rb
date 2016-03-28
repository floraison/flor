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

  def heat=(t)

    @heat = t
  end

  def execute

    @node['rets'] = []

    receive
  end

  def receive

    return reply if @node['applied']

    ms = sequence_receive

    return ms if ms.first['point'] == 'execute'

    src =
      @heat[0, 2] == [ '_proc', 'apply' ] ?
      @node['rets'].shift[1] :               # shift!
      @heat[1]

    ms = apply(src, @node['rets'], tree[2])

    @node['applied'] = ms.first['nid']

    ms
  end

  protected

  def apply(fun, args, line)

    fni = fun['nid'] # fun nid
    cni = fun['cnid'] # closure nid
    ani = Flor.sub_nid(fni, counter_next('sub')) # applied nid

    t = lookup_tree_anyway(fni)
    sig = t[1].select { |c| c[0] == '_att' }
    sig = sig.drop(1) if t[0] == 'define'

    vars = {}
    vars['arguments'] = args # should I dup?
    sig.each_with_index do |att, i|
      key = att[1].first[0]
      vars[key] = args[i]
    end

    reply(
      'point' => 'execute',
      'nid' => ani,
      'tree' => [ '_apply', t[1], line ],
      'vars' => vars,
      'cnid' => cni)
  end
end

