
class Flor::Pro::Until < Flor::Procedure
  #
  # Loops until or while a condiation evalutates to true.
  #
  # ```
  # set i 0
  # until i == 7
  #   task 'bob' "verify counter ($(i))"
  #   set i (i + 1)
  # ```
  #
  # ```
  # set i 0
  # while i < 7
  #   task 'bob' "verify counter ($(i))"
  #   set i (i + 1)
  # ```
  #
  # `until` and `while` understand `break` and `continue`, like `cursor` and
  # `loop` do.
  #
  # ```
  # until
  #   false
  #   push f.l 0
  #   set outer-break break # alias local break to "outer-break"
  #   until false
  #     push f.l 'a'
  #     outer-break 'x'
  # ```
  #
  # ## see also
  #
  # Break, continue, cursor, loop.

  names 'until', 'while'

  def pre_execute

    @node['subs'] = []

    unatt_first_unkeyed_child
  end

  def receive_first

    @node['vars'] =
      {}
    @node['vars']['break'] =
      [ '_proc', { 'proc' => 'break', 'nid' => nid }, tree[-1] ]
    @node['vars']['continue'] =
      [ '_proc', { 'proc' => 'continue', 'nid' => nid }, tree[-1] ]

    super
  end

  def receive_non_att
    #
    # receiving from a non_att child (condition or block)

    if @fcid == first_unkeyed_child_id

      t0 = tree[0]
      tru = Flor.true?(payload['ret'])

      if (tru && t0 == 'until') || ( ! tru && t0 == 'while')
        #
        # over

        ret = @node.has_key?('cret') ? @node['cret'] : node_payload_ret

        wrap_reply('ret' => ret)

      else
        #
        # condition yield false, enter "block"

        payload['ret'] = node_payload_ret

        execute_child(@ncid, @node['subs'].last)
      end

    elsif @ncid >= children.size
      #
      # block over, increment counter and head back to condition

      @node['subs'] << counter_next('subs')

      @node['cret'] = payload['ret']
      payload['ret'] = node_payload_ret

      execute_child(first_unkeyed_child_id, @node['subs'].last)

    else
      #
      # we're in the middle of the "block", let's carry on

      # no need to set 'ret', we're in some kind of sequence
      execute_child(@ncid, @node['subs'].last)
    end
  end

  def cancel_when_closed

    return cancel if node_status_flavour == 'on-error'
    return [] if @message['flavour'] != 'break'

    cancel
  end

  def cancel

    if @message['flavour'] == 'continue'

      pl = node_payload.copy_current
      pl = pl.merge!(payload.copy_current)

      @node['subs'] << counter_next('subs')

      @node['on_receive_last'] =
        execute_child(
          first_unkeyed_child_id, @node['subs'].last, 'payload' => pl)

    else

      @node['on_receive_last'] = nil
    end

    super
  end
end

