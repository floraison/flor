
class Flor::Pro::Not < Flor::Procedure

  name 'not'

  def receive_last

    payload['ret'] = ! Flor.true?(payload['ret'])

    super
  end
end

