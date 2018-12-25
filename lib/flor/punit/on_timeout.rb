
class Flor::Pro::OnTimeout < Flor::Procedure
  #
  # Counterpart to the on_timeout: attribute.
  #
  # Sets the on_timeout "attribute" of the parent procedure.
  #
  # ```
  # set l []
  # sequence timeout: '1s'
  #   push l 0
  #   on_timeout (def msg \ push l "$(msg.point):$(msg.nid)")
  #   stall _
  #   push l 2
  # push l 3
  # ```
  # Ends up with `[ 0, 'cancel:0_1', 3 ]` in the variable `l`. The on_timeout
  # is set on the "sequence".
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

    ms = super

    ms.first['from_on'] = 'timeout'

    ms
  end
end

