
class Flor::Pro::Trace < Flor::Procedure

  name 'trace'

  def receive

    if @message['point'] == 'receive'

      t = lookup_tree(@message['from'])

      if t.first == '_att' && t[1].size == 1
        @executor.unit.storage.trace(exid, nid, 'trace', payload['ret'])
      end
    end

    super
  end

  def receive_last

    payload['ret'] = node_payload_ret

    wrap
  end
end

