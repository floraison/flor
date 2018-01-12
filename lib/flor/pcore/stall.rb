
class Flor::Pro::Stall < Flor::Procedure
  #
  # "stall" is mostly used in flor tests. It simply dead ends.
  #
  # It receives its execution message, executes all its attributes but
  # does not answer to its parent procedure, effectively stalling
  # its branch of the execution.
  #
  # ## see also
  #
  # _skip

  name 'stall'

  def receive_last_att

    [] # give back no messages, just stall...
  end
end

