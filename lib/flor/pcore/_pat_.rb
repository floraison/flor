
class Flor::Pro::PatContainer < Flor::Procedure

  def pre_execute

    @node['binding'] = {}
  end

  def execute

    if tree[1] == 0 || tree[1] == []
      payload['_pat_binding'] = val == [] ? {} : nil
      payload.delete('_pat_val')
      return wrap_reply
    end

    super
  end

  def execute_child(index=0, sub=nil, h=nil)

    ct = child_type(index)

    return wrap_reply(
      'nid' => nid, 'from' => Flor.child_nid(nid, index, sub)
    ) if ct.is_a?(String) || ct.is_a?(Array)

    payload['_pat_val'] = sub_val if ct == :pattern

    super(index, sub, h)
  end

  protected

  def val

    node_payload['_pat_val'] || node_payload_ret
  end

  def child_type(cid_or_tree)

    ct = cid_or_tree.is_a?(Array) ? cid_or_tree : tree[1][cid_or_tree]
    ct0 = ct[0]

    return :att if ct0 == '_att'
    return :pattern if %w[ _pat_arr _pat_obj _pat_or _pat_bind ].include?(ct0)
    return '_' if ct0 == '_'
    return ct0 if ct0.match(/\A[a-z][a-z0-9]*\z/) && ct[1] == []

    m = ct0.match(Flor::SPLAT_REGEX)
    return [ m[1], m[2] == '_' ? nil : m[2].to_i ] if m

    nil # nothing special
  end

  def wrap_no_match_reply

    payload['_pat_binding'] = nil
    payload.delete('_pat_val')

    wrap_reply
  end
end

