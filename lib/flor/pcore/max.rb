
class Flor::Pro::Max < Flor::Procedure

  names %w[ max min ]

  def pre_execute

    @node['atts'] = []
    @node['ret'] ||= receive_payload_ret

    unatt_unkeyed_children
  end

  def receive_payload_ret

    case ret = payload['ret']
    when Array then ret
    when Hash then ret.values
    else false
    end
  end

  def receive_last

    ret = @node['ret']

    fail Flor::FlorError.new(
      "found no argument that can #{@node['heap']}", self
    ) unless ret

    lax = att('lax', 'loose') == true
    types = ret.collect { |e| Flor.type(e) }

    ret = ret.collect { |x| JSON.dump(x) } if lax && types != [ 'number' ]

    r =
      begin
        ret.send(@node['heap'])
      rescue
        fail unless lax
        nil
      end
    res =
      r ?
      @node['ret'][ret.index { |e| e == r }] :
      nil

    wrap_reply('ret' => res)
  end
end

