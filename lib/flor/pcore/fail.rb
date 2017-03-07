
class Flor::Pro::Fail < Flor::Procedure
  #
  # Explicitely raises an error.
  #
  # ```
  # fail "not enough water in the tank"
  #   # or
  # error "not enough water in the tank"
  # ```
  #
  # (I prefer "fail" because it's a verb over "error", pick the one you like)

  names 'fail', 'error'

  def receive_last

    err =
      Flor::FlorError.new(
        (payload['ret'] || 'error').to_s,
        Flor::Node.new(@executor, @node, @message))

    #fail err
      #
      # let's reply with the failed message directly,
      # no need for a Ruby backtrace, it's an error at the Flor level.
      #
    reply('point' => 'failed', 'error' => Flor.to_error(err))
  end
end

