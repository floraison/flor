
class Flor::Pro::TypeOf < Flor::Procedure

  names %w[ type-of type ]

  def pre_execute

    unatt_unkeyed_children
  end

  def receive_last

    wrap('ret' => Flor.type(payload['ret']).to_s)
  end
end

