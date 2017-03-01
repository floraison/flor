
class Flor::Pro::Case < Flor::Procedure

  name 'case'

  def pre_execute

    unatt_unkeyed_children
  end

  def receive_non_att

    return reply if @node['found']

    return receive_array if @node.has_key?('key')

    @node['key'] = payload['ret']
    super
  end

  protected

  def receive_array

    a = payload['ret']
    a = a.nil? ? [ a ] : Array(a)

    payload['ret'] = node_payload_ret

    if a.include?(@node['key'])

      @node['found'] = true
      execute_child(@fcid + 1)

    else

      t = tree[1][@fcid + 2]

      if t && t[0, 2] == [ 'else', [] ]
        @node['found'] = true
        execute_child(@fcid + 3)
      else
        execute_child(@fcid + 2)
      end
    end
  end
end

