
class Flor::Pro::PatBind < Flor::Pro::PatContainer

  name '_pat_bind'

  def pre_execute

    unatt_unkeyed_children
    stringify_first_child
  end

  def receive_non_att

    key = @node['key']

    unless key
      @node['key'] = payload['ret'].to_s
      return super
    end

    b = payload['_pat_binding']
    b[key] = val if b

    wrap_reply
  end
end

