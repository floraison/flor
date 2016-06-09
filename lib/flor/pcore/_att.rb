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

    k = key
    m = "receive_#{k}"

    respond_to?(m, true) ? send(m) : receive_att(k)
      # use `true` to include protected methods
  end

  protected

  def key

    return nil if children.size < 2

    children.first[0]
  end

  def receive_att(key)

    if parent_node['atts']
      parent_node['atts'] << [ key, payload['ret'] ]
      parent_node['mtime'] = Flor.tstamp
    end

    payload['ret'] = @node['ret'] if key

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

    pt = parent_node_tree

    return receive_att('tags') \
      if pt && Flor::Procedure[pt[0]].names.first == 'trap'

    tags = Array(payload['ret'])

    (parent_node['tags'] ||= []).concat(tags)
    parent_node['tags'].uniq!

    reply('point' => 'entered', 'tags' => tags) +
    reply
  end
  alias receive_tags receive_tag

  def receive_timeout

    n = parent
    m = reply('point' => 'cancel', 'nid' => n, 'flavour' => 'timeout').first
    t = payload['ret']

    schedule('in' => t, 'nid' => n, 'message' => m) +
    reply
  end
end

