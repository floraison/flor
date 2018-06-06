
class Flor::Pro::OnTimeout < Flor::Procedure
  #
  # Counterpart to the on_timeout: attribute.
  #
  # TODO
  #
  # ## see also
  #
  # On, on_error, on_cancel.

  name 'on_timeout'

  def pre_execute

    unatt_unkeyed_children
  end

  def receive_non_att

    store_on(:timeout)

    super
  end
end

