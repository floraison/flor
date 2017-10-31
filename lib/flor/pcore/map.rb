
class Flor::Pro::Map < Flor::Pro::Iterator

  names %w[ map ]

  def pre_iterations

    @node['res'] = []
  end

  def receive_iteration

    @node['res'] << payload['ret']
  end

  def end_iterations

    wrap_reply('ret' => @node['res'])
  end
end

