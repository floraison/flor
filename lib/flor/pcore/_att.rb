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


class Flor::Pro::Att < Flor::Procedure

  name '_att'

  def execute

    return reply if children == [ [ '_', [], tree[2] ] ]

    pt = parent_node['tree']
    return reply if pt && pt[0] == '_apply'

    @node['ret'] = Flor.dup(payload['ret']) \
      if key
      #if %w[ vars ].include?(key)

    execute_child(children.size - 1)
  end

  def receive

    if k = key

      m = "receive_#{k}"

      return respond_to?(m, true) ? send(m) : receive_att(k)
        # use `true` to include protected methods
    end

    reply
  end

  protected

  def key

    return nil if children.size < 2

    children.first[0]
  end

  # default
  #
  def receive_att(key)

    if parent_node.has_key?('atts')
      atts = parent_node['atts']
      atts[key] = payload['ret'] if atts.is_a?(Hash)
      payload['ret'] = @node['ret']
    end

    reply
  end

  # vars: { ... }, inits a scope for the parent node
  #
  def receive_vars

    parent_node['vars'] = payload['ret']
    payload['ret'] = @node['ret']

    reply
  end

  def receive_tag

    tag = payload['ret']
    parent_node['tag'] = tag

    reply('point' => 'entered', 'tag' => tag) +
    reply
  end
end

