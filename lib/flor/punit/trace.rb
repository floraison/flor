
class Flor::Pro::Trace < Flor::Procedure

  name 'trace'

  def receive

    t = lookup_tree(@message['from'])

    @executor.unit.storage.trace(exid, nid, 'trace', payload['ret']) \
      if point == 'receive' && (t[0] != '_att' || t[1].size == 1)

    super
  end

  def receive_last

    payload['ret'] = node_payload_ret

    super
  end
end

