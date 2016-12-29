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


class Flor::Pro::Skip < Flor::Procedure
  #
  # Skips x messages, mostly used for testing flor.
  #
  # ```
  # concurrence
  #   sequence
  #     set f.i 0
  #     while tag: 'xx'
  #       true
  #       set f.i (+ f.i 1)
  #   sequence
  #     _skip 7 # after 7 messages will go on
  #     break ref: 'xx'
  # ```

  name '_skip'

  def receive

    return super unless @node.has_key?('count')

    @node['count'] -= 1

    return reply if @node['count'] < 1

    reply('nid' => nid, 'from' => Flor.child_nid(nid, children.size))
  end

  def receive_last

    @node['count'] = payload['ret'].to_i + 1
    payload['ret'] = node_payload_ret

    receive
  end
end

