
class Flor::Pro::Set < Flor::Procedure

  names %w[ set setr ]

  def pre_execute

    unatt_unkeyed_children

    non_att_children[0..-2]
      .each_with_index { |_, i| stringify_child(i) }
        #
        # don't stringify the last non att child

    @node['refs'] = []
  end

  def receive_non_att

    ret = payload['ret']
    last = (@fcid + 1) == children.size

    @node['refs'] << ret if ! last && ret.is_a?(String)

    super
  end

  def receive_last

    if @node['refs'].size == 1
      set_value(@node['refs'].first, payload['ret'])
    else
      splat
    end

    payload['ret'] =
      if tree[0] == 'setr' || @node['refs'].last == 'f.ret'
        payload['ret']
      else
        node_payload_ret
      end

    wrap_reply
  end

  protected

  SPLAT_REGEX = /\A(.*)__(_|\d+)\z/

  def splat

    refs = @node['refs'].dup
    a = payload['ret'].dup

    loop do

      ref = refs.shift; break unless ref

      if m = SPLAT_REGEX.match(ref)
        r, l = m[1, 2]
        l = l == '_' ? a.length - refs.length : l.to_i
        set_value(r, a[0, l]) if r.length > 0
        a = a.drop(l)
      else
        set_value(ref, a.shift)
      end
    end
  end
end

