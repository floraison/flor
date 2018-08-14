
class Flor::Pro::Shuffle < Flor::Procedure

  names %w[ shuffle ]

  def pre_execute

    unatt_unkeyed_children

    @node['atts'] = []
    @node['rets'] = []
  end

  def receive_last

    arr =
      (@node['rets'] + [ node_payload_ret ])
        .find { |r| r.is_a?(Array) }

    fail Flor::FlorError.new("no array to #{@node['heat0']}") unless arr

    cnt =
      att('count', nil) ||
      @node['rets'].find { |r| r.is_a?(Integer) } ||
      arr.size

    wrap('ret' => arr.sample(cnt))
  end
end

