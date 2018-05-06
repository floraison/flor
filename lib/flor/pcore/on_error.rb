
class Flor::Pro::OnError < Flor::Procedure

  name 'on_error'

  def pre_execute

    unatt_unkeyed_children
  end

  def receive_non_att

    store_on(:error)

    super
  end
end

