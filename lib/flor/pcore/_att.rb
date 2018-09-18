
class Flor::Pro::Att < Flor::Procedure

  name '_att'

  def execute

    return wrap_reply if children == [ [ '_', [], tree[2] ] ]
      # spares 1 message

    pt = parent_node['tree']
    return wrap_reply if pt && pt[0] == '_apply'

    m = "pre_execute_#{children[0][0]}"
    send(m) if respond_to?(m, true)

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

  #
  # execute phase

  def pre_execute_boolean_attribute

    return unless children.size == 1

    t = @node['tree'] = Flor.dup(tree)
    t[1] << [ '_boo', true, @node['tree'][2] ]
  end

  alias pre_execute_flank pre_execute_boolean_attribute

  def pre_execute_vars

    return unless children.size == 2 && children[1][0] == '_obj'

    t = tree

    return if t[1][1][1] == 0 # [ '_obj', 0, 123 ]

    t = @node['tree'] = Flor.dup(t)

    t[1][1][1].unshift([
      '_att', [ [ 'quote', [], -1 ], [ '_sqs', 'keys', -1 ] ], -1 ])
  end

  #
  # receive phase

  def receive_unkeyed

    receive_att(nil)
  end

  def receive_keyed

    if Flor.child_id(@message['from']) == 0
      ret = payload['ret']
      @node['key'] = k = unref(ret, :key)
      as = (parent_node || {})['atts_accepting_symbols'] || []
      execute_child(1, nil, 'accept_symbol' => as.include?(k))
    else
      k = @node['key']
      m = "receive_#{k}"
      respond_to?(m, true) ? send(m) : receive_att(k)
    end
  end

  def unref(k, flavour=:key)

    return k unless Flor.is_tree?(k)
    return k unless k[1].is_a?(Hash)
    return k unless %w[ _proc _tasker _func ].include?(k[0])

    (flavour == :key ? nil : k[1]['oref']) ||
    k[1]['ref'] ||
    k[1]['proc'] || k[1]['tasker']
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

  # `vars: { ... }` inits a scope for the parent node
  # `vars: 'copy'` copies the parent scope and use as local scope
  # `vars: [ 'a', 'b' ]` inits a new scope containing vars a and b
  #
  def receive_vars

    vars =
      case (vs = payload['ret'])
      when 'copy', '*' then copy_vars
      when Array then wlist_vars(vs)
      else vs
      end

    (parent_node['vars'] ||= {}).merge!(vars)

    wrap('ret' => @node['ret'])
  end

  def copy_vars

    @executor.vars(nid)
      # Returns a hash of all the vars known at point `nid` of the execution
  end

  def wlist_vars(vs)

    mode =
      case vs.first
      when '+' then '+'
      when '-', '^', '!' then '-'
      #else nil
      end
    vs.shift if mode

    vs = vs.collect { |v| Flor.is_regex_tree?(v) ? Flor.to_regex(v) : v }
    vars = copy_vars

    if mode == '-'
      Hash[vars.map { |k, v| [ k, var_match?(vs, k) ? nil : v ] }]
    else
      Hash[vars.map { |k, v| [ k, var_match?(vs, k) ? v : nil ] }]
    end
  end

  def var_match?(vs, key)

    vs.each do |v|
      return true if v == key
      return true if v.is_a?(Regexp) && v =~ key
    end

    false
  end

  def parent_is_trap?

    pt = parent_node_tree; return false unless pt
    pt0 = pt[0]; return false unless pt0.is_a?(String)
    pro = Flor::Procedure[pt0]; return false unless pro
    pro.names.include?('trap')
  end

  def receive_tag

    return receive_att('tags') if parent_is_trap?

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

  def receive_on_error; store_on(:error); wrap_reply; end
  def receive_on_cancel; store_on(:cancel); wrap_reply; end
  def receive_on_timeout; store_on(:timeout); wrap_reply; end

  def receive_flank

    return wrap_reply unless Flor.true?(payload['ret'])
    return wrap_reply unless parent_node

    Flor::Procedure.make(@executor, parent_node, @message).flank +
    wrap_reply
  end
end

