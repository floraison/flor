
# # trap
#
# ## range:/scope:
# * subnid (default)
# * execution/exe
# * domain
# * subdomain
#
# ## bind:
# * parent (default)
# * root
#
class Flor::Pro::Trap < Flor::Procedure
  #
  # Watches the messages emitted in the execution and reacts when
  # a message matches certain criteria.
  #
  # Once the trap is set (once the execution interprets its branch), it
  # will trigger for any matching message, unless the `count:` attribute
  # is set.
  #
  # When the execution terminates, the trap is removed as well.
  #
  # By default, the observation range is the execution, only messages
  # in the execution where the trap was set are considered.
  # The trap can be extended via the `range:` attribute.
  #
  # "trap" triggers a function, while "on" triggers a block.
  #
  # ## the point: criterion
  #
  # The simplest thing to trap is a 'point'. Here, the trap is set for
  # any message whose point is 'terminated':
  # ```
  # sequence
  #   trap 'terminated'
  #     def msg \ trace "terminated(f:$(msg.from))"
  #   trace "here($(nid))"
  #     # OR
  # #sequence
  # #  trap 'terminated'
  # #    def msg \ trace "terminated(f:$(msg.from))"
  # #  trace "here($(nid))"
  # ```
  #
  # ## the heap: criterion
  # ## the heat: criterion
  #
  # ## the tag: criterion (and name:)
  #
  # TODO
  #
  # ## the signal: short criterion
  # ## the tag: short criterion
  #
  # ## the range: limit
  #
  # TODO
  #
  # ## the count: limit
  #
  # ```
  # trap tag: 'x' count: 2
  #   # ...
  # ```
  # will trigger when the execution enters the tag 'x', but will trigger only
  # twice.
  #
  # ## see also
  #
  # On and signal.

  name 'trap'

  def pre_execute

    @node['vars'] = {}
    @node['atts'] = []
    @node['fun'] = nil

    #unatt_unkeyed_children
  end

  def receive_non_att

    return execute_child(@ncid) if children[@ncid]

    fun = @fcid > 0 ? payload['ret'] : nil

    points = att_a('point', 'points', nil)
    tags = att_a('tag', 'tags', nil)
    heats = att_a('heat', 'heats', nil)
    heaps = att_a('heap', 'heaps', nil)
    names = att_a('name', 'names', nil)
    pl = att('payload', 'pl') || 'trap'

    points = att_a(nil, nil) unless points || tags
    points = [ 'entered' ] if tags && ! points

    att_a('sig', 'signal', 'signals', [])
      .each { |sig| (points ||= []) << 'signal'; (names ||= []) << sig }

    points = points.uniq if points
    names = names.uniq if names

    msg =
      if fun
        apply(fun, [], tree[2], anid: false).first
      else
        wrap_reply.first
      end

    tra = {}
    tra['nid'] = nid
    tra['bnid'] = parent || '0'
    tra['points'] = points
    tra['tags'] = tags
    tra['heaps'] = heaps
    tra['heats'] = heats
    tra['names'] = names
    tra['message'] = msg
    tra['pl'] = pl

    count = att('count')
    count = 1 if fun == nil # blocking mode implies count: 1
    tra['count'] = count if count

    tra['range'] = att('range') || att('scope') || 'subnid'

    @node['trapped'] = true

    wrap('point' => 'trap', 'nid' => nid, 'trap' => tra) +
    (fun ? flank : [])
  end

  def receive_last

    receive_non_att
  end

  def receive

    return [] if @node['trapped']
    super
  end

  # "trap" keeps track of its children, but does not cascade 'cancel' to them,
  # unless the cancel flavour is 'kill'.
  #
  def wrap_cancel_children(h={})

    h['flavour'] == 'kill' ? super : []
  end
end

