
class Flor::Pro::Concurrence < Flor::Procedure
  #
  # Executes its children concurrently.
  #
  # ```
  # concurrence
  #   #
  #   # 'alpha' and 'bravo' will be tasked concurrently.
  #   #
  #   task 'alpha'
  #   task 'bravo'
  #   #
  #   # this concurrence will reply to its parent node when 'alpha' and 'bravo'
  #   # will both have replied.
  # ```
  #
  # ## payload merging
  #
  # by default, all the children replies are merged, with the first to
  # reply having the upper hand.
  # ```
  # concurrence
  #   set f.a 0
  #   set f.a 1
  #   set f.b 2
  # # will result in a payload of { a: 0, b: 2 } (first child replies first
  # # in those simplistic settings)
  # ```
  #
  # ## the expect: attribute
  #
  # Tells the concurrence how many children replies are expected at most.
  # Once that could is reached, remaining children are cancelled by default.
  # ```
  # concurrence expect: 1
  #   set f.a 0
  #   set f.b 1
  # ```
  #
  # ## the remaining: attribute
  #
  # As seen above, `expect:` will let the concurrence cancel the children
  # that have not yet replied once the expected count is reached.
  # With `remaining:` one can tell the concurrence to simply forget them,
  # they will go on and their, future, reply will be discarded (the concurrence
  # being already gone).
  #
  # `remaining:` may be shortened to `rem:`.
  # ```
  # concurrence expect: 1 rem: 'forget'
  #   task 'alpha'
  #   task 'bravo'
  # # will forget child 'alpha' as soon as child 'bravo' replies,
  # # and vice versa.
  # ```

  name 'concurrence'

  def pre_execute

    @node['atts'] = []
  end

  def receive_last_att

    return wrap_reply unless children[@ncid]

    (@ncid..children.size - 1)
      .map { |i| execute_child(i, 0, 'payload' => payload.copy_current) }
      .flatten(1)
        #
        # call execute for each of the (non _att) children
  end

  def receive_non_att

    @node['receiver'] ||= determine_receiver
    @node['merger'] ||= determine_merger

    cnodes.delete(from)

    return [] if @node['over']

    over = invoke_receiver
      # true: the concurrence is over, false: the concurrence is still waiting

    return [] unless over

    @node['over'] = true

    pld = invoke_merger
      # determine post-concurrence payload

    cancel_remaining +
    wrap_reply('payload' => pld)
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

    wrap_cancel_children
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

