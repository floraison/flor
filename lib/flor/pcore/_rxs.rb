
class Flor::Pro::RegularExpressionString < Flor::Procedure

  name '_rxs'

  def pre_execute

    @node['rets'] = []
  end

  def execute_child(index=0, sub=nil, h=nil)

    payload['ret'] = node_payload_ret
      # always pass the noe_payload_ret to children

    super
  end

  def receive_last

p @node['rets']
    wrap('ret' => @node['rets'].collect(&:to_s).join)
  end
end

