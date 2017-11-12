
class Flor::Pro::Iterator < Flor::Procedure

  def pre_execute

    @node['vars'] ||= {}

    @node['ocol'] = nil # original collection
    @node['col'] = nil # collection
    @node['idx'] = -1
    @node['fun'] = nil

    pre_iterator

    unatt_unkeyed_children
  end

  def receive_non_att

    unless @node['col']
      @node['ocol'] = ocol =
        if Flor.is_func_tree?(payload['ret'])
          node_payload_ret
        else
          payload['ret']
        end
      @node['col'] =
        Flor.to_coll(ocol)
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

    return end_iterator if iterator_over?

    idx = @node['idx']
    elt = @node['col'][idx]

    vars =
      if @node['ocol'].is_a?(Array)
        { 'elt' => elt, 'idx' => idx }
      else
        { 'key' => elt[0], 'val' => elt[1], 'idx' => idx }
      end

    args = vars.values
    vars.each { |k, v| @node['vars'][k] = v }

    apply(@node['fun'], args, tree[2])
  end

  protected

  def pre_iterator

    @node['res'] = []
  end

  def iterator_over?

    @node['idx'] == @node['col'].size
  end

  def end_iterator

    wrap_reply('ret' => iterator_result)
  end
end


class Flor::Macro::Iterator < Flor::Macro

  def rewrite_iterator_tree(procedure_name)

    atts = att_children

    l = tree[2]

    th = [ procedure_name, [], l, *tree[3] ]
    atts.each { |ac| th[1] << Flor.dup(ac) }

    if non_att_children.any?

      td = [ 'def', [], l ]
      td[1] << [ '_att', [ [ 'elt', [], l ] ], l ]
      non_att_children.each { |nac| td[1] << Flor.dup(nac) }

      th[1] << td
    end

    th
  end
end

