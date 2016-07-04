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

  def receive_last_att

    #@node['original_children'] = Flor.dup(children)

    cn =
      non_att_children.collect { |c|
        [ '_timer',
          c[1].select { |cc|
            cc[0] == '_att' &&
            cc[1].is_a?(Array) &&
            cc[1][0] &&
            cc[1][0].is_a?(Array) &&
            (cc[1][0][0] == 'after' || cc[1][0][0] == 'at')
          },
          c[2] ]
      }

    @node['tree'] = [ tree[0], cn, tree[2] ]

    super
  end

  def receive_non_att

    super
  end
end

