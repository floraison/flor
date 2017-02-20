
class Flor::Pro::Concurrence < Flor::Procedure

  name 'concurrence'

  def pre_execute

    @node['atts'] = []
  end

  def receive_last_att

    return reply unless children[@ncid]

    (@ncid..children.size - 1)
      .map { |i| execute_child(i, 0, 'payload' => payload.copy_current) }
      .flatten(1)
        #
        # call execute for each of the (non _att) children
  end

  def receive_non_att

    @node['receiver'] ||= determine_receiver
    @node['merger'] ||= determine_merger

    (@node['cnodes'] || []).delete(from)

    return [] if @node['over']

    over = invoke_receiver
      # true: the concurrence is over, false: the concurrence is still waiting

    return [] unless over

    @node['over'] = true

    pld = invoke_merger
      # determine post-concurrence payload

    cancel_remaining +
    reply('payload' => pld)
  end

  def receive_from_child_when_closed

    ms = receive

    return [] if ms.empty?

    pop_on_receive_last || ms
  end

  protected

  def determine_receiver

    ex = att(:expect)

    return 'expect_integer_receive' if ex && ex.is_a?(Integer) && ex > 0

    'default_receive'
  end

  def determine_merger

    'default_merge'
  end

  def cancel_remaining

    # remaining:
    # * 'cancel' (default)
    # * 'forget'
    # * 'wait'

    rem = att(:remaining, :rem)

    return [] if rem == 'forget'

    cancel_nodes(@node['cnodes'])
  end

  def invoke_receiver

    # TODO: receiver function case

    self.send(@node['receiver'])
  end

  def invoke_merger

    # TODO: merger function case

    self.send(@node['merger'])
  end

  def store_payload

    (@node['payloads'] ||= {})[@message['from']] =
      @message['payload']
  end

  def default_receive

    store_payload

    @node['payloads'].size >= non_att_children.size
  end

  def expect_integer_receive

    store_payload

    @node['payloads'].size >= att(:expect)
  end

  def default_merge

    @node['payloads'].values
      .reverse
      .inject({}) { |h, pl| h.merge!(pl) }
  end
end

