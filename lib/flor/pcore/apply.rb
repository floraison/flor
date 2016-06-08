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

  def pre_execute

    @node['arts'] = []
  end

  def do_receive

    return reply if @node['applied']

    arts = @node['arts'].collect(&:last)

    src = @heat[0, 2] == [ '_proc', 'apply' ] ?  arts.shift : @heat

    ms = apply(src, arts, tree[2])

    @node['applied'] = ms.first['nid']

    ms
  end

#  def receive
#
#    return reply if @node['applied']
#
#    ms = sequence_receive
#
#    return ms if ms.first['point'] == 'execute'
#
#    src =
#      @heat[0, 2] == [ '_proc', 'apply' ] ?
#      @node['rets'].shift :
#      @heat
#
#    ms = apply(src, @node['rets'], tree[2])
#
#    @node['applied'] = ms.first['nid']
#
#    ms
#  end
end

