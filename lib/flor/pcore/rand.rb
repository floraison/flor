
class Flor::Pro::Rand < Flor::Procedure

  name 'rand'

  def receive_last

    payload['ret'] = rand(payload['ret'])

    reply
  end
end

