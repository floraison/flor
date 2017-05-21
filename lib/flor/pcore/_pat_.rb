
class Flor::Pro::PatContainer < Flor::Procedure

  def pre_execute

    @node['binding'] = {}
  end

  def execute_child(index=0, sub=nil, h=nil)

    ct = child_type(index)

    return wrap_reply(
      'nid' => nid, 'from' => Flor.child_nid(nid, index, sub)
    ) if ct.is_a?(String) # short circuit

#    if ct == :pattern
## TODO inject _pat_val
## TODO rectify f.ret
#    end

    super(index, sub, h)
  end

  protected

  def val

    node_payload['_pat_val'] || node_payload_ret
  end

  def child_type(cid)

    ct = tree[1][cid]; ct0 = ct[0]

    return :pattern if ct0 == '_pat_arr' || ct0 == '_pat_obj'
    return '_' if ct0 == '_'
    return ct0 if ct0.match(/\A[a-z][a-z0-9]*\z/) && ct[1] == []
    nil # nothing special
  end

  def wrap_no_match_reply

    payload['_pat_binding'] = nil

    wrap_reply
  end
end

class Flor::Pro::PatArr < Flor::Pro::PatContainer

  name '_pat_arr'

  def pre_execute

    @node['index'] = 0

    super
  end

  def receive_non_att

    ct = child_type(@fcid)
#p [ :rna, :fcid, @fcid, :index, @node['index'], :ct, ct ]

    if ct == :pattern
# TODO
    elsif ct.is_a?(String)
      @node['binding'][ct] = val[@node['index']] if ct != '_'
    elsif val[@node['index']] != payload['ret']
      return wrap_no_match_reply
    end

    @node['index'] = @node['index'] + 1

    super
  end

  def receive_last

    payload['_pat_binding'] = @node['binding']

    super
  end

  protected
end

class Flor::Pro::PatObj < Flor::Pro::PatContainer

  name '_pat_obj'
end

