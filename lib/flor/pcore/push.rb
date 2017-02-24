
class Flor::Pro::Push < Flor::Procedure

  names 'push', 'pushr'

  def pre_execute

    unatt_unkeyed_children
    stringify_first_child
  end

  def receive_non_att

    @node['arr'] ||= payload['ret']

    super
  end

  def receive_last

    arr = @node['arr']

    if arr.is_a?(String)
      payload.copy if arr[0, 1] == 'f'
      arr = lookup(arr)
    end

    fail Flor::FlorError.new(
      "cannot push to given target (#{arr.class})", self
    ) unless arr.respond_to?(:push)

    val =
      unkeyed_children.size > 1 ?
      payload['ret'] :
      node_payload_ret

    arr.push(val)

    payload['ret'] = node_payload_ret \
      unless tree[0] == 'pushr'

    reply
  end
end

