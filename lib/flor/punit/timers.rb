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


class Flor::Pro::Timers < Flor::Procedure

  names %w[ timer timers ]

  def pre_execute

    fail "no parent node for #{tree[0].inspect} at line #{tree[2]}" \
      unless parent_node

    super
  end

  def receive_last_att

    @node['tree'] = rewrite(tree)

    super
  end

  def receive_non_att

    super
  end

  protected

  def rewrite(t)

    timeatts =
      t[1].select { |c|
        c[0] == '_att' &&
        c[1].is_a?(Array) &&
        c[1][0] &&
        c[1][0].is_a?(Array) &&
        %w[ after at in ].include?(c[1][0][0])
      }

    return [ t[0], t[1].collect { |c| rewrite(c) }, t[2] ] if timeatts.empty?

    timeatts.unshift(
      [ '_att',  [ [ '_timeout', [], t[2] ], [ '_boo', true, t[2] ] ], t[2] ]
    ) if t[0] == 'timeout'

    [ '_timer', timeatts, t[2] ]
  end
end

