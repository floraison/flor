
class Flor::Pro::If < Flor::Procedure
  #
  # The classical "if" (and its "unless" sidequick)

  names %w[ if unless ife unlesse ]
    #
    # removing "ife" and "unlesse" leas to
    # LoadError: cannot load such file -- sequel/adapters/
    # when running spec/unit/ and spec/punit/
    # weird...

  def pre_execute

    unatt_unkeyed_children
  end

  def receive_non_att

    return reply if @fcid > first_unkeyed_child_id
      # "else" or "then" answered, replying to parent...

    off =
      if tree[0] == 'unless' || tree[0] == 'unlesse'
        Flor.false?(payload['ret']) ? 1 : 2
      else # 'if' or 'ife'
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

