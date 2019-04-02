
# Module extracted out of "concurrence", deals with receivers and mergers.
#
# Should it deal with remainder?
#
module Flor::Pro::ReceiveAndMerge

  protected

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

  def mm__default_merge # should be mm__first, better to keep initial default

    @node['payloads'].values
      .reverse
      .inject { |h, pl| Flor.deep_merge!(h, pl) }
  end

  def mm__last

    @node['payloads'].values
      .inject { |h, pl| Flor.deep_merge!(h, pl) }
  end

  def mm__first_plain

    @node['payloads'].values
      .reverse
      .inject { |h, pl| h.merge!(pl) }
  end

  def mm__last_plain

    @node['payloads'].values
      .inject { |h, pl| h.merge!(pl) }
  end

  def mm__top

    @node['payloads']
      .sort_by { |k, _| k }
      .collect(&:last)
      .reverse
      .inject { |h, pl| Flor.deep_merge!(h, pl) }
  end

  def mm__bottom

    @node['payloads']
      .sort_by { |k, _| k }
      .collect(&:last)
      .inject { |h, pl| Flor.deep_merge!(h, pl) }
  end

  def mm__top_plain

    @node['payloads']
      .sort_by { |k, _| k }
      .collect(&:last)
      .reverse
      .inject { |h, pl| h.merge!(pl) }
  end

  def mm__bottom_plain

    @node['payloads']
      .sort_by { |k, _| k }
      .collect(&:last)
      .inject { |h, pl| h.merge!(pl) }
  end

  def determine_receiver

    ex = att(:expect)

    return 'expect_integer_receive' if ex && ex.is_a?(Integer) && ex > 0

    att(:on_receive, :receiver) || 'default_receive'
  end

  def determine_merger

    # first or last to reply
    # top or bottom of the list (the concurrence)

    case m = att(:on_merge, :merger, :merge)
    when nil, 'f', 'first' then 'default_merge'
    when 'l' then 'last'
    when 'p', 'plain', 'fp' then 'first_plain'
    when 'lp' then 'last_plain'
    when 't', 'n', 'north' then 'top'
    when 'b', 's', 'south' then 'bottom'
    when 'tp', 'np', 'north plain' then 'top_plain'
    when 'bp', 'sp', 'south plain' then 'bottom_plain'
    when String then  m.to_s.gsub(/\s+/, '_')
    else m
    end
  end
end

