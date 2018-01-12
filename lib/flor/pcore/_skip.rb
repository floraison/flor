
class Flor::Pro::Skip < Flor::Procedure
  #
  # Skips x messages, mostly used for testing flor.
  #
  # ```
  # concurrence
  #   sequence
  #     set f.i 0
  #     while tag: 'xx'
  #       true
  #       set f.i (+ f.i 1)
  #   sequence
  #     _skip 7 # after 7 messages will go on
  #     break ref: 'xx'
  # ```
  #
  # ## see also
  #
  # Stall.

  name '_skip'

  def receive

    return super unless @node.has_key?('count')

    @node['count'] -= 1

    return wrap_reply if @node['count'] < 1

    wrap_reply('nid' => nid, 'from' => Flor.child_nid(nid, children.size))
  end

  def receive_last

    @node['count'] = payload['ret'].to_i
    payload['ret'] = node_payload_ret

    receive
  end
end

