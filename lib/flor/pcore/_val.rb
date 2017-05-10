
class Flor::Pro::Val < Flor::Procedure

  name '_val'

  def wrap_reply

    if node_open?

      heat = @node['heat']
      #heat = nil if heat == [ '_proc', 'val', -1 ] || heat[0] == '_nul'
      heat = nil if heat[0] == '_nul'

      payload['ret'] = heat
    end

    super
  end
end

