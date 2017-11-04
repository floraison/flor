
class Flor::Pro::Iterator < Flor::Procedure

  def pre_execute

    @node['vars'] ||= {}

    @node['col'] = nil # collection
    @node['cot'] = nil # collection type
    @node['idx'] = -1
    @node['fun'] = nil

    pre_iterations

    unatt_unkeyed_children
  end

  def receive_non_att

    unless @node['col']
      col =
        if Flor.is_func_tree?(payload['ret'])
          node_payload_ret
        else
          payload['ret']
        end
      @node['col'] = Flor.to_coll(col)
      @node['cot'] = col.is_a?(Hash) ? 'object' : 'array'
    end

    return execute_child(@ncid) \
      if @node['fun'] == nil && children[@ncid] != nil

    if @node['idx'] < 0
      @node['fun'] = payload['ret']
    else
      receive_iteration
    end

    @node['idx'] += 1
    @node['mtime'] = Flor.tstamp

    return end_iterations \
      if @node['idx'] == @node['col'].size

    @node['vars']['idx'] = @node['idx']

    idx = @node['idx']
    elt = @node['col'][idx]

    args =
      if @node['cot'] == 'object'
        [ elt[0], elt[1], idx ]
      else
        [ elt, idx ]
      end

    apply(@node['fun'], args, tree[2])
  end
end

