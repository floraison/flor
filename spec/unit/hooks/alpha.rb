
class AlphaHook #< Flor::BasicHook

  def on(message)

    $seen << Flor.dup(message)

    [] # return empty list of new messages
  end
end

