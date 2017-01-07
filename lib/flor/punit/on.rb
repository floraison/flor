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


class Flor::Pro::On < Flor::Macro
  #
  # Traps a signal by name
  #
  # Turns
  # ```
  # on 'approve'
  #   task 'bob' mission: 'gather signatures'
  # ```
  # into
  # ```
  # trap point: 'signal', name: 'approve'
  #   set sig 'signal'
  #   def msg
  #     task 'bob' mission: 'gather signatures'
  # ```
  #

  name 'on'

  def rewrite_tree

    atts = att_children
    signame_i = atts.index { |at| at[1].size == 1 }

    fail ArgumentError.new(
      "signal name not found in #{tree.inspect}"
    ) unless signame_i

    tname = atts[signame_i]
    tname = Flor.dup(tname[1][0])
    atts.delete_at(signame_i)

    l = tree[2]

    th = [ 'trap', [], l, *tree[3] ]
    th[1] << [ '_att', [ [ 'point', [], l ], [ '_sqs', 'signal', l ] ], l ]
    th[1] << [ '_att', [ [ 'name', [], l ], tname ], l ]
    atts.each { |ac| th[1] << Flor.dup(ac) }

    th[1] << [ 'set', [
      [ '_att', [ [ 'sig', [], l ] ], l ],
      tname
    ], l ]

    td = [ 'def', [], l ]
    td[1] << [ '_att', [ [ 'msg', [], l ] ], l ]
    non_att_children.each { |nac| td[1] << Flor.dup(nac) }

    th[1] << td

    th
  end
end

