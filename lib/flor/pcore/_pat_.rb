
class Flor::Pro::PatContainer < Flor::Procedure

  def pre_execute

    @node['binding'] = {}
  end

  def execute_child(index=0, sub=nil, h=nil)

    ct = child_type(index)

    return wrap_reply(
      'nid' => nid, 'from' => Flor.child_nid(nid, index, sub)
    ) if ct.is_a?(String) || ct.is_a?(Array)

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

  def child_type(cid_or_tree)

    ct = cid_or_tree.is_a?(Array) ? cid_or_tree : tree[1][cid_or_tree]
    ct0 = ct[0]

    return :att if ct0 == '_att'
    return :pattern if ct0 == '_pat_arr' || ct0 == '_pat_obj'
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

class Flor::Pro::PatArr < Flor::Pro::PatContainer

  name '_pat_arr'

  def pre_execute

    @node['index'] = 0

    super
  end

  def receive_non_att

    ct = child_type(@fcid)
#p [ :rna, :fcid, @fcid, :index, @node['index'], :ct, ct ]

    offset = 1

    if ct == :pattern

# TODO

    elsif ct.is_a?(String)

      @node['binding'][ct] = val[@node['index']] if ct != '_'

    elsif ct.is_a?(Array)

      offset = val[@node['index']..-1].size - remaining_index_count
      @node['binding'][ct[0]] = val[@node['index'], offset]

    elsif val[@node['index']] != payload['ret']

      return wrap_no_match_reply
    end

    @node['index'] = @node['index'] + offset

    super
  end

  def receive_last

    payload['_pat_binding'] = @node['binding']
#    payload.delete('_pat_val')

    super
  end

  protected

#  def debug(opts={})
#
#    nkeys = %w[ nid heat0 ] + (opts[:nkeys] || [])
#
#    puts Flor.colours.green + "---procedure-debug- #{object_id}"
#    caller[0, 3].each { |l| puts "  #{l}" }
#    print '  '; p(fcid: @fcid, ncid: @ncid)
#    print '  '; p(@node.select { |k, v| nkeys.include?(k) })
#    children.each_with_index { |ct, i| puts "  #{i}: #{ct.inspect}" }
#    puts "---procedure-debug- #{object_id}." + Flor.colours.reset
#  end

  def remaining_index_count

#debug(nkeys: %w[ val index binding ])
    children[@ncid..-1]
      .inject(0) { |count, nact|
        count +
        case (ct = child_type(nact))
        when Array then ct[1] || 1 # FIXME !!!
        when :att then 0
        else 1
        end }
  end
end

class Flor::Pro::PatObj < Flor::Pro::PatContainer

  name '_pat_obj'
end

