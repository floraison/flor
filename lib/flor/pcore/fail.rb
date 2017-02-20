
class Flor::Pro::Fail < Flor::Procedure

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

