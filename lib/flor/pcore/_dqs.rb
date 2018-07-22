
class Flor::Pro::DoubleQuoteString < Flor::Procedure

  name '_dqs'

  def pre_execute

    @node['rets'] = []
  end

  def execute_child(index=0, sub=nil, h=nil)

    payload['ret'] = node_payload_ret
      # always pass the noe_payload_ret to children

    super
  end

  def receive_last

    wrap('ret' => @node['rets'].collect { |e| to_string(e) }.join)
  end

  protected

  def to_string(result)

    case result
    when String then result
    else JSON.dump(result)
    end
  end
end

