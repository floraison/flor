
class Flor::Pro::RegularExpressionString < Flor::Procedure

  name '_rxs'

  def pre_execute

    @node['rets'] = []
    @node['atts'] = []
  end

  def execute_child(index=0, sub=nil, h=nil)

    payload['ret'] = node_payload_ret
      # always pass the noe_payload_ret to children

    super
  end

  def receive_last

    rex = [ '_rxs', "/#{@node['rets'].join}/#{att('rxopts')}", tree[2] ]

    wrap('ret' => rex)
  end
end

