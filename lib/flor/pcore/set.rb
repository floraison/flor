
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
      Flor.splat(@node['refs'], payload['ret']).each { |k, v| set_value(k, v) }
    end

    payload['ret'] =
      if tree[0] == 'setr' || @node['refs'].last == 'f.ret'
        payload['ret']
      else
        node_payload_ret
      end

    wrap_reply
  end
end

