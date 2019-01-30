
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

    @node['on_receive_nids'] = nil
    @node['on_receive_queue'] = []

    pre_execute_rewrite
  end

  def receive_last_att

    return wrap_reply unless children[@ncid]

    @node['receiver'] = determine_receiver
    @node['merger'] = determine_merger


    branches = (@ncid..children.size - 1).to_a
    @node['branch_count'] = branches.count

    ms = branches
      .map { |i| execute_child(i, 0, 'payload' => payload.copy_current) }
      .flatten(1)
        #
        # call execute for each of the (non _att) children

    oce = att('on_child_error')
    ms.each { |m| m['on_error_handler'] = oce } if oce

    ms
  end

  def receive_non_att

    if message['from_on']
      super
      #receive_from_on
    elsif Flor.same_sub?(nid, from)
      receive_from_branch
    elsif from_error_handler?
      wrap_reply
    elsif @node['on_receive_nids'] && @node['on_receive_nids'][0] == from
      receive_from_receiver
    else
      receive_from_merger
    end
  end

  protected


  def receive_from_child_when_closed

    ms = receive

    return [] if ms.empty?

    pop_on_receive_last || ms
  end

  def receive_from_branch

    @node['payloads'][from] = @message['payload']

    apply_receiver
  end

  def apply_receiver

    if @node['receiver'].is_a?(String)
      apply_receiver_method
    else
      apply_receiver_function
    end
  end

  def apply_receiver_method

    ret = send('rm__' + @node['receiver'])
    msg = { 'payload' => { 'ret' => ret } }

    receive_from_receiver(msg)
  end

  def apply_receiver_function

    @node['on_receive_queue'] << from

    dequeue_receiver_function
  end

  def dequeue_receiver_function

    if @node['on_receive_nids']
      []
    elsif f = @node['on_receive_queue'].shift
      ms = apply(@node['receiver'], receiver_args(f), tree[2])
      @node['on_receive_nids'] = [ ms.first['nid'], f ]
      ms
    else
      []
    end
  end

  def receiver_args(from)

    rs = Flor.dup(@node['payloads'])

    [ [ 'reply', rs[from] ],
      [ 'from', from ],
      [ 'replies', rs ],
      [ 'branch_count', @node['branch_count'] ],
      [ 'over', !! @node['over'] ] ]
  end

  def receive_from_receiver(msg=message)

    ret = msg['payload']['ret']
    over = @node['over']

    if ret.is_a?(Hash) && ret.keys == %w[ done payload ]
      over = over || ret['done']
      from = @node['on_receive_nids'][1]
      @node['payloads'][from] = ret['payload']
    else
      over = over || ret
    end

    @node['on_receive_nids'] = nil

    just_over = over && ! @node['over']

    @node['over'] ||= just_over

    if just_over
      apply_merger
    elsif ! over
      [] # wait for more branches
    else
      receive_from_merger(nil)
    end +
    dequeue_receiver_function
  end

  def apply_merger

    if @node['merger'].is_a?(String)
      apply_merger_method
    else
      apply_merger_function
    end
  end

  def apply_merger_method

    pld = send('mm__' + @node['merger'])
    msg = { 'payload' => pld }

    receive_from_merger(msg)
  end

  def apply_merger_function

    apply(@node['merger'], merger_args, tree[2])
  end

  def merger_args

    rs = Flor.dup(@node['payloads'])

    [ [ 'rets', rs.inject({}) { |h, (k, v)| h[k] = v['ret']; h } ],
      [ 'replies', rs ],
      [ 'branch_count', @node['branch_count'] ] ]
  end

  def receive_from_merger(msg=message)

    pl = msg ? msg['payload'] : {}
    ret = pl['ret']

    pl = ret['payload'] \
      if ret.is_a?(Hash) && ret.keys == %w[ done payload ]

    # TODO somehow, what if done is false, should we un-over the concurrence?

    @node['merged_payload'] = pl \
      if msg && ! @node.has_key?('merged_payload')

    rem = determine_remainder

    cancel_children(rem) + reply_to_parent(rem)
  end

  def rm__default_receive

    @node['payloads'].size >= non_att_count
  end

  def rm__expect_integer_receive

    @node['payloads'].size >= att(:expect)
  end

  def mm__default_merge

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

  def make_on_def(cn, l)

    c0 = cn.length == 1 ? cn[0] : nil

    return c0 if Flor.is_definition_tree?(c0)
    return make_on_def(c0[1], l) if Flor.is_att_tree?(c0)

    [ 'def', cn, l ]
  end

  def rewrite_as_attribute(child_tree)

    ct0, ct1, ct2 = child_tree

    k = [ ct0, [], ct2 ]
    v = make_on_def(ct1, ct2)

    [ '_att', [ k, v ], ct2 ]
  end

  def pre_execute_rewrite

    t = tree
    t1 = t[1]

    return if t1.empty?

    atts, cldn =
      t1.inject([ [], [] ]) { |r, ct|
        if ct[0] == '_att'
          r[0] << ct
        elsif %w[ on_receive on_merge ].include?(ct[0])
          r[0] << rewrite_as_attribute(ct)
        else
          r[1] << ct
        end
        r }

    nt1 = atts + cldn

    @node['tree'] = [ t[0], nt1, *t[2..-1] ] \
      if nt1 != t1
  end
end

