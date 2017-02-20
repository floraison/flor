
class Flor::Pro::Arr < Flor::Procedure

  name '_arr'

  def pre_execute

    @node['rets'] = []
  end

  def receive

    return reply('ret' => []) if children == 0

    super
  end

  def receive_last

    payload['ret'] = @node['rets']

    reply
  end
end

