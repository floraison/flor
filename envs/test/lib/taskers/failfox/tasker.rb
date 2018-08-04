
class EchoTasker < Flor::BasicTasker

  def task

    payload['error'] = 'Echo error'
    message['point'] = 'failed'

    reply
  end
end

