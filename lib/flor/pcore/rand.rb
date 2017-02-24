
class Flor::Pro::Rand < Flor::Procedure

  name 'rand'

  def receive_last

    arg = payload['ret']

    fail ArgumentError.new(
      "'rand' expects an integer or a float"
    ) unless (arg.is_a?(Integer) || arg.is_a?(Float))

    payload['ret'] = Random.rand(arg)

    reply
  end
end

