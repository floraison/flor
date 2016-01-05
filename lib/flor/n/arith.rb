

class Flor::Ins::Arith < Flor::Instruction

  register_as '+', '-'

  def execute
    :over
  end
end

