

class Flor::Ins::Val < Flor::Instruction

  def execute

    @msg['payload']['ret'] = duplicate(attributes['_0'])

    :over
  end
end

