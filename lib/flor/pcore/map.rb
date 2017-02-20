
class Flor::Pro::Map < Flor::Procedure

  name 'map'

  def pre_execute

    #@node['ret'] = Flor.dup(payload['ret']) # now using @node['payload']

    @node['vars'] = {}
      # just to store the local idx

    @node['col'] = nil
    @node['idx'] = -1
    @node['fun'] = nil
    @node['res'] = []

    unatt_unkeyed_children
  end

  def receive_non_att

    @node['col'] ||=
      Flor.to_coll(
        if Flor.is_func_tree?(payload['ret'])
          node_payload_ret
        else
          payload['ret']
        end)

    return execute_child(@ncid) \
      if @node['fun'] == nil && children[@ncid] != nil

    if @node['idx'] < 0
      @node['fun'] = payload['ret']
    else
      @node['res'] << payload['ret']
    end

    @node['idx'] += 1
    @node['mtime'] = Flor.tstamp

    return reply('ret' => @node['res']) \
      if @node['idx'] == @node['col'].size

    @node['vars']['idx'] = @node['idx']

    apply(@node['fun'], @node['col'][@node['idx'], 1], tree[2])
  end
end

