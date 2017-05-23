
class Flor::Pro::PatObj < Flor::Pro::PatContainer

  name '_pat_obj'

  def pre_execute

    @node['atts'] = []

    super
  end

  def receive_first

    return wrap_no_match_reply if ! val.is_a?(Hash)

    super
  end

  def receive_last_att

    rewrite_keys

    @node['key'] = nil

    super
  end

  def receive_non_att

    key = @node['key']
    ret = payload['ret']

    unless key
      ret = ret.to_s
      return wrap_no_match_reply unless val.has_key?(ret)
      @node['key'] = ret
      return super
    end

    ct = child_type(@fcid)

    if ct == :pattern

# TODO

    elsif ct.is_a?(String)

      @node['binding'][ct] = val[@node['key']] if ct != '_'

    elsif ct.is_a?(Array)

      @node['binding'][ct[0]] = val[@node['key']] if ct[0].length > 0

    elsif val[key] != ret

      return wrap_no_match_reply unless val[key] == ret
    end

    @node['key'] = nil

    super
  end

  def receive_last

    payload['_pat_binding'] = @node['binding']
    payload.delete('_pat_val')

    super
  end

  protected

  def rewrite_keys

    q = (att('quote') == 'keys')

    key = true

    cn = children
      .collect { |ct|
        next ct if ct[0] == '_att'
        key = ! key
        next ct if key
        q ? quote_key(ct) : deref_and_stringify(ct) }

    t = tree

    @node['tree'] = [ t[0], cn, *t[2..-1] ] if cn != t[1]
  end

  def quote_key(t)

    if t[1] == []
      [ '_sqs', t[0], *t[2..-1] ]
    else
      t
    end
  end
end

