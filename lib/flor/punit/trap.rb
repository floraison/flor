
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
        apply(fun, [], tree[2], false).first
      else
        reply.first
      end

    tra = {}
    tra['bnid'] = parent || '0' # shouldn't it be [the real] root?
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

    queue('point' => 'trap','nid' => nid, 'trap' => tra) +
    (fun ? reply : [])
  end

  def receive_last

    receive_non_att
  end

  def receive

    return [] if @node['trapped']
    super
  end
end

