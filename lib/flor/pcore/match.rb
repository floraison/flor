
class Flor::Pro::Match < Flor::Procedure

  name 'match'

  def pre_execute

    unatt_unkeyed_children
  end

  def receive_non_att

    if @node['found']
      return wrap_reply
    end

    if ! @node.has_key?('val')
      @node['val'] = payload['ret']
      return super
    end

    if match?
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

  protected

  def match?

    case (v = @node['val'])
    when Array then match_array?
    when Hash then match_object?
    else v == payload['ret']
    end
  end

  def match_array?

false
  end

  def match_object?

false
  end
end

