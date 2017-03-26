
class Flor::Pro::Signal < Flor::Procedure

  name 'signal'

  def pre_execute

    @node['atts'] = []
  end

  def receive_last

    name = att('name', nil)

    return super unless name

    wrap(
      'point' => 'signal', 'nid' => nid, 'name' => name,
      'payload' => payload.copy_current
    ) + super
  end
end

