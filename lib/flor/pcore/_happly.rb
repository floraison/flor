
class Flor::Pro::Happly < Flor::Procedure

  name '_happly'

  def pre_execute

    @node['atts'] = []
  end

  def execute

    wrap(
      'point' => 'execute',
      'nid' => Flor.child_nid(nid, tree[1].size),
      'tree' => tree[0])
  end

  def receive

    fcid = Flor.child_id(message['from'])

    return wrap_reply if @node['applied']
    return super unless fcid == tree[1].size

    ret = payload['ret']

    @node['hret'] = payload['ret']
    execute_child(0)
  end

  def receive_last

    hret = @node['hret']

    return wrap_reply('ret' => hret) unless Flor.is_func_tree?(hret)

    args = @node['atts'].collect(&:last)

    hret[1].merge!('nid' => nid)

    msgs = apply(hret, args, tree[2])

    @node['applied'] = msgs.first['nid']

    msgs
  end
end

