
class Flor::Pro::Val < Flor::Procedure

  name '_val'

  def execute

    heat = @node['heat']
    heat = nil if heat == [ '_proc', 'val', -1 ]

    payload['ret'] = heat

    reply
  end
end

