
class Flor::Pro::Cond < Flor::Procedure

  name 'cond'

  def receive_non_att

    return execute_child(0) if @message['point'] == 'execute'
    return reply if @node['found']

    tf2 = tree[1][@fcid + 2]

    if Flor.true?(payload['ret'])
      @node['found'] = true
      execute_child(@fcid + 1)
    elsif tf2 && tf2[0, 2] == [ 'else', [] ]
      @node['found'] = true
      execute_child(@fcid + 3)
    else
      execute_child(@fcid + 2)
    end
  end

  protected

  def execute_child(i)

    payload['ret'] = node_payload_ret unless tree[1][i]

    super(i)
  end
end

