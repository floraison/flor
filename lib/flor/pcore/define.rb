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


class Flor::Pro::Define < Flor::Procedure
  #
  # Defines a function.
  #
  # In its `define` flavour, will take a function body and assign it to
  # variable.
  # ```
  # define sum a, b # make variable 'sum' hold the function
  #   +
  #     a
  #     b
  #   # yields the function, like `fun` and `def` do
  #
  # sum 1 2
  #   # will yield 3
  # ```
  #
  # In the `fun` and `def` flavours, the function is unnamed, it's thus not
  # bound in a local variable.
  # ```
  # map [ 1, 2, 3 ]
  #   def x
  #     + x 3
  # # yields [ 4, 5, 6 ]
  # ```
  #
  # It's OK to generate the function name at the last moment:
  # ```
  # sequence
  #   set prefix "my"
  #   define "$(prefix)-sum" a b
  #     + a b
  # ```

  names %w[ def fun define ]

  def execute

    if i = att_children.index { |c| %w[ _dqs _sqs ].include?(c[1].first.first) }
      execute_child(i)
    else
      receive_att
    end
  end

  def receive_att

    t = tree
    cnode = lookup_var_node(@node, 'l')
    cnid = cnode['nid']
    fun = @executor.counter_next('funs') - 1
    (cnode['closures'] ||= []) << fun

    val = [ '_func', { 'nid' => nid, 'cnid' => cnid, 'fun' => fun }, t[2] ]

    if t[0] == 'define'
      name =
        if @message['point'] == 'execute'
          t[1].first[1].first[0]
        else
          payload['ret']
        end
      set_var('', name, val)
    end

    payload['ret'] = val

    reply
  end
end

