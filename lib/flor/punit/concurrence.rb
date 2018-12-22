
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
  #
  # ```
  # concurrence expect: 1 rem: 'forget'
  #     #
  #     # will forget child 'alpha' as soon as child 'bravo' replies,
  #     # and vice versa.
  #     #
  #   task 'alpha'
  #   task 'bravo'
  # ```
  #
  # ```
  # concurrence expect: 1 rem: 'wait'
  #     #
  #     # if 'alpha' replies before 'bravo', the concurrence will wait for
  #     # 'bravo', without cancelling it. And vice versa.
  #     #
  #   task 'alpha'
  #   task 'bravo'
  # ```

  name 'concurrence'

  def pre_execute

    @node['atts'] = []
    @node['payloads'] = {}
  end

  def receive_last_att

    return wrap_reply unless children[@ncid]

    @node['receiver'] = determine_receiver
    @node['merger'] = determine_merger

    (@ncid..children.size - 1)
      .map { |i| execute_child(i, 0, 'payload' => payload.copy_current) }
      .flatten(1)
        #
        # call execute for each of the (non _att) children
  end

  def receive_non_att

    if message['from_on']
      super
      #receive_from_on
    elsif Flor.same_sub?(nid, from)
      receive_from_branch
    else
      receive_from_sub
    end
  end

  protected

  def receive_from_branch

    @node['payloads'][from] = @message['payload']

    apply_receiver
  end

  def receive_from_sub

fail NotImplementedError # TODO
  end

  def apply_receiver

    if @node['receiver'].is_a?(String)
      apply_receiver_method
    else
      apply_receiver_function
    end
  end

  def apply_receiver_method

    ret = send(@node['receiver'])
    msg = { 'payload' => { 'ret' => ret } }

    receive_from_receiver(msg)
  end

  def apply_receiver_function

    apply(@node['receiver'], receiver_args, tree[2])
  end

  def receive_from_receiver(msg=message)

    over = @node['over'] || msg['payload']['ret']
    just_over = over && ! @node['over']
    @node['over'] ||= just_over

    if just_over
      apply_merger
    elsif ! over
      [] # wait for more branches
    else
#[]
receive_from_merger(nil) # FIXME
    end
  end

  def apply_merger

    if @node['merger'].is_a?(String)
      apply_merger_method
    else
      apply_merger_function
    end
  end

  def apply_merger_method

    ret = send(@node['merger'])
    msg = { 'payload' => { 'ret' => ret } }

    receive_from_merger(msg)
  end

  def apply_merger_function

    apply(@node['merger'], merger_args, tree[2])
  end

  def receive_from_merger(msg=message)

    #return [] if @node['merged_payload'] # already over

    if msg
      @node['merged_payload'] ||= msg['payload']['ret']
    end

    rem = determine_remainder

    cancel_children(rem) + reply_to_parent(rem)
  end

  def default_receive

    @node['payloads'].size >= non_att_count
  end

  def expect_integer_receive

    @node['payloads'].size >= att(:expect)
  end

  def default_merge

    @node['payloads'].values
      .reverse
      .inject({}) { |h, pl| h.merge!(pl) }
  end

  def determine_remainder

    att(:remaining, :rem) || 'cancel'
  end

  def determine_receiver

    ex = att(:expect)

    return 'expect_integer_receive' if ex && ex.is_a?(Integer) && ex > 0

    att(:on_receive, :receiver) || 'default_receive'
  end

  def determine_merger

    att(:on_merge, :merger) || 'default_merge'
  end

  def cancel_children(rem)

    (rem && rem != 'forget') ? wrap_cancel_children : []
  end

  def reply_to_parent(rem)

    return [] \
      if @node['replied']
    return [] \
      if @node['payloads'].size < non_att_count && ( ! rem || rem == 'wait')

    @node['replied'] = true

    wrap_reply('payload' => @node['merged_payload'])
  end

  def receive_from_child_when_closed

    ms = receive

    return [] if ms.empty?

    pop_on_receive_last || ms
  end

    ############################################################################
    #
    # rem: cancel/forget/wait
    # expect: {int}
    # on_merge/merger: {fun}
    #
    ############################################################################
    #
    # define m  from,   replies,  over
    #           '0_1',  {},       false
    #           1,      {},       false
    #           1,      {},       false / {} payload
    #
    # define m  from, replies, over, child_count, wip <-- why not?
    #
    #   returns nil/false -> not over, true -> over
    #   returns nil/false -> not over, {} payload -> over
    #
    # saturation?
    #
    ############################################################################
    # replies
    #   { '0' => xxx,
    #     '1' => yyy,
    #     'children_count' => 7 }
    ############################################################################

#  def receive_last_att
#
#    return wrap_reply unless children[@ncid]
#
#    @node['receiver'] = determine_receiver
#    @node['merger'] = determine_merger
#
#    (@ncid..children.size - 1)
#      .map { |i| execute_child(i, 0, 'payload' => payload.copy_current) }
#      .flatten(1)
#        #
#        # call execute for each of the (non _att) children
#  end
#
#  def receive_non_att
#
#    @node['payloads'][@message['from']] = @message['payload']
#
#    over = @node['over'] || invoke_receiver
#    just_over = over && ! @node['over']
#    @node['over'] ||= just_over
#
#    @node['merged_payload'] ||= just_over ? invoke_merger : nil
#    rem = just_over ? determine_remainder : nil
#
#    cancel_children(rem) + reply_to_parent(rem)
#  end

#  protected
#
#  def determine_receiver
#
#    ex = att(:expect)
#
#    return 'expect_integer_receive' if ex && ex.is_a?(Integer) && ex > 0
#
#    'default_receive'
#  end
#
#  def determine_merger
#
#    om = att(:on_merge, :merger)
#
#    if Flor.is_func_tree?(om)
#      'func_merge'
#    #else if om.is_a?(String)
#    #  "#{om}_merge"
#    else
#      'default_merge'
#    end
#  end
#
#  def invoke_receiver; self.send(@node['receiver']); end
#  def invoke_merger; self.send(@node['merger']); end
#
#  def func_merge
#
#    #om = att(:on_merge, :merger)
#
#pp @node['payloads']
#
#    default_merge
#  end
end

