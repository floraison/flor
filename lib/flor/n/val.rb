

class Flor::Ins::Val < Flor::Instruction

  def execute

    @msg['payload']['ret'] = Flor.dup(attributes['_0'])

    :over
  end
end

