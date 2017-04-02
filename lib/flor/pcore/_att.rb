
class Flor::Pro::Att < Flor::Procedure

  name '_att'

  SYMBOL_ATTS = %w[ flank ]

  def execute

    return wrap_reply if children == [ [ '_', [], tree[2] ] ]
      # spares 1 message

    pt = parent_node['tree']
    return wrap_reply if pt && pt[0] == '_apply'

    if children.size == 1 && SYMBOL_ATTS.include?(children[0][0])
      @node['tree'] = Flor.dup(tree)
      @node['tree'][1] << [ '_boo', true, @node['tree'][2] ]
    end

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
      ret = payload['ret']
      ret = ret[1]['task'] if Flor.is_task_tree?(ret)
      @node['key'] = k = ret
      as = (parent_node || {})['atts_accepting_symbols'] || []
      execute_child(1, nil, 'accept_symbol' => as.include?(k))
    else
      k = @node['key']
      m = "receive_#{k}"
      respond_to?(m, true) ? send(m) : receive_att(k)
    end
  end

  def unref(k, flavour=:key)

    #return lookup_var_name(@node, k) if Flor.is_func_tree?(k)
      # old style

    return k unless Flor.is_tree?(k)
    return k unless k[1].is_a?(Hash)
    return k unless %w[ _proc _task _func ].include?(k[0])

    (flavour == :key ? nil : k[1]['oref']) ||
    k[1]['ref'] ||
    k[1]['proc'] || k[1]['task']
  end

  def receive_att(key)

    if parent_node['atts']
      parent_node['atts'] << [ unref(key), payload['ret'] ]
      parent_node['mtime'] = Flor.tstamp
    elsif key == nil && parent_node['rets']
      parent_node['rets'] << payload['ret']
      parent_node['mtime'] = Flor.tstamp
    end

    payload['ret'] = @node['ret'] if key

    wrap_reply
  end

  # vars: { ... }, inits a scope for the parent node
  #
  def receive_vars

    parent_node['vars'] = payload['ret']
    payload['ret'] = @node['ret']

    wrap_reply
  end

  def receive_tag

    pt = parent_node_tree

    return receive_att('tags') \
      if pt && pt[0].is_a?(String) && Flor::Procedure[pt[0]].names[0] == 'trap'

    ret = payload['ret']
    ret = unref(ret, :att)

    tags = Array(ret)

    return wrap_reply if tags.empty?

    (parent_node['tags'] ||= []).concat(tags)
    parent_node['tags'].uniq!

    wrap('point' => 'entered', 'tags' => tags) +
    wrap_reply
  end
  alias receive_tags receive_tag

  def receive_ret

    if pn = parent_node
      pn['aret'] = Flor.dup(payload['ret'])
    end

    wrap_reply
  end

  def receive_timeout

    n = parent
    m = wrap_cancel('nid' => n, 'flavour' => 'timeout').first
    t = payload['ret']

    wrap_schedule('type' => 'in', 'string' => t, 'nid' => n, 'message' => m) +
    wrap_reply
  end

  def receive_on_error

    oe = payload['ret']
    oe[1]['on_error'] = true

    (parent_node['on_error'] ||= []) << oe

    wrap_reply
  end

  def receive_flank

    return wrap_reply unless Flor.true?(payload['ret'])
    return wrap_reply unless parent_node

    Flor::Procedure.new(@executor, parent_node, @message).flank +
    wrap_reply
  end
end

