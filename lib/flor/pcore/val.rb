
class Flor::Pro::Val < Flor::Procedure

  name '_val'

  def execute

    heat = @node['heat']
    heat = nil if heat == [ '_proc', 'val', -1 ] || heat[0] == '_nul'

    payload['ret'] = heat

    reply
  end
end

