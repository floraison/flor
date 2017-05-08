
class Flor::Pro::Push < Flor::Procedure

  names %w[ push pushr ]

  def pre_execute

    unatt_unkeyed_children
    stringify_first_child
  end

  def receive_non_att

    if ! @node['arr']
      @node['arr'] = payload['ret']
    else
      @node['to_push'] = payload['ret']
    end

    super
  end

  def receive_last

    push(@node.has_key?('to_push') ? @node['to_push'] : node_payload_ret)

    payload['ret'] = node_payload_ret \
      unless tree[0] == 'pushr'

    wrap_reply
  end

  protected

  def push(val)

    arr = @node['arr']

    if arr.is_a?(String)
      payload.copy if arr[0, 1] == 'f'
      arr = lookup(arr)
    end

    fail Flor::FlorError.new(
      "cannot push to given target (#{arr.class})", self
    ) unless arr.respond_to?(:push)

    arr.push(val)
  end
end

