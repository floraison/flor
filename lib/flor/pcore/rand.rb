
class Flor::Pro::Rand < Flor::Procedure

  name 'rand'

  def receive_last

    payload['ret'] = Random.rand(payload['ret'])

    reply
  end
end

