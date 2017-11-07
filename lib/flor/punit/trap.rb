
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

