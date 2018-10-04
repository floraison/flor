
class Flor::Pro::Stall < Flor::Procedure
  #
  # Mostly used in flor tests. Stalls the current branch of execution.
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

