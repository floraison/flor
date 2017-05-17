
class Flor::Pro::Map < Flor::Procedure

  names %w[ map for-each ]

  def pre_execute

    @node['vars'] ||= {}

    @node['col'] = nil
    @node['idx'] = -1
    @node['fun'] = nil

    @node['res'] = @node['heat0'] == 'map' ? [] : nil

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
    elsif res = @node['res']
      res << payload['ret']
    end

    @node['idx'] += 1
    @node['mtime'] = Flor.tstamp

    if @node['idx'] == @node['col'].size
      if res = @node['res']
        payload['ret'] = @node['res']
      end
      return wrap_reply
    end

    @node['vars']['idx'] = @node['idx']

    apply(@node['fun'], @node['col'][@node['idx'], 1], tree[2])
  end
end

