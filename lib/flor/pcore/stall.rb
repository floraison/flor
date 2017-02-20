
class Flor::Pro::Stall < Flor::Procedure

  name 'stall'

  def receive_last_att

    [] # give back no messages, just stall...
  end
end

