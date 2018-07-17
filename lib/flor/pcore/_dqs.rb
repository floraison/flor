
class Flor::Pro::DoubleQuoteString < Flor::Procedure

  name '_dqs'

  def pre_execute

    @node['rets'] = []
  end

  def receive_last

    wrap('ret' => @node['rets'].collect { |e| to_string(e) }.join)
  end

  protected

  def to_string(result)

    case result
    when String then result
    else JSON.stringify(result)
    end
  end
end

