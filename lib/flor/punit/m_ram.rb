# frozen_string_literal: true

# Module extracted out of "concurrence", deals with receivers and mergers.
#
# Should it deal with remainder?
#
module Flor::Pro::ReceiveAndMerge

  protected

  def receive_from_branch

    (@node['payloads'] ||= {})[from] = @message['payload']

    apply_receiver
  end

  def apply_receiver

    @node['receiver'] ||= determine_receiver

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

    (@node['on_receive_queue'] ||= []) << from

    dequeue_receiver_function
  end

  def dequeue_receiver_function

    if @node['on_receive_nids']
      []
    elsif f = (@node['on_receive_queue'] || []).shift
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

    if (m = determine_merger).is_a?(Hash)
      apply_merger_method(m)
    else
      apply_merger_function(m)
    end
  end

  def apply_merger_method(h)

    o = h[:order] || h['order']
    m = h[:merger] || h['merger']

    payloads = send("mom__#{o}", h, Flor.dup(@node['payloads']))
    payload = send("mmm__#{m}", h, payloads)
    msg = { 'payload' => payload }

    receive_from_merger(msg)
  end

  def apply_merger_function(func_tree)

    @node['merging'] = true

    apply(func_tree, merger_args, tree[2])
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

    @node['payloads'].size >= branch_count
  end

  def rm__expect_integer_receive

    @node['payloads'].size >= att(:expect)
  end

  def determine_receiver

    ex = att(:expect)

    return 'expect_integer_receive' if ex && ex.is_a?(Integer) && ex > 0

    att(:on_receive, :receiver) || 'default_receive'
  end

  # order:
  # * first, last: first or last to reply
  # * top/north/head, bottom/south/tail: position in concurrence, in collection
  #
  # merge:
  # * deep
  # * mix/plain
  # * override
  # * ignore
  # * stack

  STACK_REX = /\Astack(?::([-_a-zA-Z0-9]+))?\z/.freeze

  TRANSLATORS = { STACK_REX => 'k', /\Atail\z/ => 'a' }.freeze

  MORDERS = {
    'f' => :first, 'l' => :last, /[tnh]/ => :north, /[bsa]/ => :south }.freeze
  MMERGERS = {
    'd' => :deep, /[mp]/ => :mix, 'o' => :override, 'i' => :ignore,
    'k' => :stack }.freeze

  def default_merger

    { order: :first, merger: :deep }
  end

  def determine_merger

    m = att(:on_merge, :merger, :merge)
    h = default_merger

    return h if m == nil
    return m unless m.is_a?(String)

    mm = m.split(/[-\s_]+/)
    mm = mm[0].chars if mm.size == 1 && mm[0].size < 3
      #
    d = mm
      .collect { |s| TRANSLATORS.inject(s) { |r, (k, v)| r.match(k) ? v : r } }
      .collect { |s| s[0, 1] }.join

    MORDERS.each do |rex, order|
      if d.match(rex); h[:order] = order; break; end
    end
    MMERGERS.each do |rex, merger|
      if d.match(rex); h[:merger] = merger; break; end
    end

    h[:key] = m.match(STACK_REX)[1] \
      if h[:merger] == :stack

    h
  end

  def mom__first(h, payloads)
    mom__last(h, payloads).reverse
  end
  def mom__last(_, payloads)
    payloads.values
  end
  def mom__north(h, payloads)
    mom__south(h, payloads).reverse
  end
  def mom__south(_, payloads)
    payloads.sort_by { |k, _| k }.collect(&:last)
  end

  def mmm__deep(_, ordered_payloads)
    ordered_payloads.inject { |h, pl| Flor.deep_merge!(h, pl) }
  end
  def mmm__mix(_, ordered_payloads)
    ordered_payloads.inject { |h, pl| h.merge!(pl) }
  end
  def mmm__override(_, ordered_payloads)
    ordered_payloads.last
  end
  def mmm__ignore(_, _)
    node_payload.copy
  end
  def mmm__stack(h, ordered_payloads)
    k = h[:key] || 'ret'
    node_payload.copy.merge!(k => ordered_payloads.reverse)
  end

  def determine_remainder

    att(:remaining, :rem) || 'cancel'
  end

  def cancel_children(rem)

    (rem && rem != 'forget') ? wrap_cancel_children : []
  end

  def reply_to_parent(rem)

    return [] \
      if @node['replied']
    return [] \
      if @node['payloads'].size < branch_count && ( ! rem || rem == 'wait')

    @node['replied'] = true

    wrap_reply('payload' => post_merge)
  end

  def post_merge

    @node['merged_payload']
  end
end

