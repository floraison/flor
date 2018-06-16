
class Flor::Pro::Index < Flor::Procedure

  name 'index'

  def pre_execute

    @node['ret'] = receive_payload_ret

    @node['rets'] = []
  end

  def receive_last

    coll = @node['ret']
    inds = @node['rets']

    r =
      if coll.is_a?(Array)
        coll[inds.first]
      elsif coll.is_a?(Hash)
        coll[inds.first]
      else
        fail Flor::FlorError.new(
          "can only index arrays or objects (not #{r.class})", self)
      end

    wrap_reply('ret' => r)
  end
end

