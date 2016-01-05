

class Flor::Ins::Val < Flor::Instruction

  register_as 'val'

  def execute

    @msg['payload']['ret'] = Flor.dup(attributes['_0'])

    :over
  end
end

