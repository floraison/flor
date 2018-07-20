
class Flor::Pro::Dol < Flor::Procedure

  name '_dol'

  def receive

    return super unless @message['point'] == 'receive'

    ret = payload['ret']

    return super if (ret.is_a?(String) && ret.length == 0) || ret == false

    wrap
  end
end

