
class BravoHook #< Flor::BasicHook

  def on(message)

    message['payload']['emil'] = 'was not here'

    [] # return empty list of new messages
  end
end

