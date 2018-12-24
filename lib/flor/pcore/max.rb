
class Flor::Pro::Max < Flor::Procedure

  names %w[ max min ]

  def pre_execute

    @node['ret'] ||= receive_payload_ret

    unatt_unkeyed_children
  end

  def receive_payload_ret

    case ret = payload['ret']
    when Array then ret
    when Hash then ret.values
    else false
    end
  end

  def receive_last

    ret = @node['ret']

    fail Flor::FlorError.new(
      "found no argument that can #{@node['heap']}", self
    ) unless ret

    r = ret.send(@node['heap'])

    wrap_reply('ret' => r)
  end
end

