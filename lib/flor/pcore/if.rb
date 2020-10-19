# frozen_string_literal: true

class Flor::Pro::If < Flor::Procedure
  #
  # The classical "if" (and its "unless" sidekick)
  #
  # ```
  # if
  #   > f.age 3
  #   set f.designation 'child' # then
  #   set f.designation 'baby' # else
  #
  # if (f.age > 3)
  #   sequence # then
  #     set f.designation 'child'
  #   sequence # else
  #     set f.designation 'baby'
  #     order_baby_food _
  # ```
  #
  # Warning, the direct children are relevant. In the following snip,
  # `order_child_seat` is considered the "else" part of the `if`
  # ```
  # if (f.age > 3)
  #   set f.designation 'child'
  #   order_child_seat _
  # ```
  #
  # ## postfix `if` and `unless`
  #
  # The flor parser will automatically turn
  # ```
  # task 'bob' if a > b
  # ```
  # into the syntax tree that would result from
  # ```
  # if
  #   a > b
  #   task 'bob'
  # ```
  #
  # ## else-if
  #
  # Currently, if an "else if" is needed, it's better to use [cond](cond.md).
  #
  #
  # ## see also
  #
  # Cond, case, match.

  names %w[ if unless ife unlesse _if _unless ]
    #
    # removing "ife" and "unlesse" leads to
    # LoadError: cannot load such file -- sequel/adapters/
    # when running spec/unit/ and spec/punit/
    # weird...

  def pre_execute

    unatt_unkeyed_children
  end

  def receive_non_att

    return wrap_reply if @fcid > first_unkeyed_child_id
      # "else" or "then" answered, replying to parent...

    off =
      case heap
      when 'unless', 'unlesse', '_unless'
        Flor.false?(payload['ret']) ? 1 : 2
      else # 'if' or 'ife'
        Flor.true?(payload['ret']) ? 1 : 2
      end

    nxt = @fcid + off

    if nxt >= children.size
      wrap_reply('ret' => node_payload_ret)
    else
      execute_child(nxt)
    end
  end
end

