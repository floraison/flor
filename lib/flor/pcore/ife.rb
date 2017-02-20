
class Flor::Pro::Ife < Flor::Procedure

  names 'ife', 'unlesse'

  def pre_execute

    unatt_unkeyed_children
  end

  def receive_non_att

    return reply if @fcid > first_unkeyed_child_id
      # "else" or "then" answered, replying to parent...

    off =
      if tree[0] == 'unlesse'
        Flor.false?(payload['ret']) ? 1 : 2
      else # 'ife'
        Flor.true?(payload['ret']) ? 1 : 2
      end

    nxt = @fcid + off

    if nxt >= children.size
      reply('ret' => node_payload_ret)
    else
      execute_child(nxt)
    end
  end
end

