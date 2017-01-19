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


class Flor::Pro::Att < Flor::Procedure

  name '_att'

  def execute

    return reply if children == [ [ '_', [], tree[2] ] ]
      # spares 1 message

    pt = parent_node['tree']
    return reply if pt && pt[0] == '_apply'

    execute_child(0, nil, 'accept_symbol' => children.size > 1)
  end

  def receive

    if children.size < 2
      receive_unkeyed
    else
      receive_keyed
    end
  end

  protected

  def receive_unkeyed

    receive_att(nil)
  end

  def receive_keyed

    if Flor.child_id(@message['from']) == 0
      @node['key'] = k = payload['ret']
      as = (parent_node || {})['atts_accepting_symbols'] || []
      execute_child(1, nil, 'accept_symbol' => as.include?(k))
    else
      k = @node['key']
      m = "receive_#{k}"
      respond_to?(m, true) ? send(m) : receive_att(k)
    end
  end

  def receive_att(key)

    if parent_node['atts']
      parent_node['atts'] << [ rekey(key), payload['ret'] ]
      parent_node['mtime'] = Flor.tstamp
    elsif key == nil && parent_node['rets']
      parent_node['rets'] << payload['ret']
      parent_node['mtime'] = Flor.tstamp
    end

    payload['ret'] = @node['ret'] if key

    reply
  end

  # Returns the task name if the key points to a task,
  # the function name if the key points to a function,
  # returns as is else.
  #
  def rekey(k)

    return k[1] if Flor.is_task_tree?(k)
    return lookup_var_name(@node, k) if Flor.is_func_tree?(k)

    k
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
      if pt && pt[0].is_a?(String) && Flor::Procedure[pt[0]].names[0] == 'trap'

    ret = payload['ret']
    fail(
      "cannot use proc #{ret[1].inspect} as tag name"
    ) if Flor.is_proc_tree?(ret)

    ret = rekey(ret)
    tags = Array(ret)

    return reply if tags.empty?

    (parent_node['tags'] ||= []).concat(tags)
    parent_node['tags'].uniq!

    reply('point' => 'entered', 'tags' => tags) +
    reply
  end
  alias receive_tags receive_tag

  def receive_ret

    if pn = parent_node
      pn['aret'] = Flor.dup(payload['ret'])
    end

    reply
  end

  def receive_timeout

    n = parent
    m = reply('point' => 'cancel', 'nid' => n, 'flavour' => 'timeout').first
    t = payload['ret']

    schedule('type' => 'in', 'string' => t, 'nid' => n, 'message' => m) +
    reply
  end

  def receive_on_error

    oe = payload['ret']
    oe[1]['on_error'] = true

    (parent_node['on_error'] ||= []) << oe

    reply
  end
end

