
class Flor::Pro::OnCancel < Flor::Procedure

  name 'on_cancel'

  def pre_execute

    unatt_unkeyed_children
  end

  def receive_non_att

    store_on(:cancel)

    super
  end
end

