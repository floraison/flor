# frozen_string_literal: true

class Flor::Pro::OnCancel < Flor::Procedure
  #
  # Counterpart to the on_cancel: attribute.
  #
  # ```
  # set f.l []
  # sequence
  #   on_cancel (def msg \ push f.l "$(msg.point):$(msg.nid)")
  #   push f.l 0
  #   cancel '0_1' # cancels the containing sequence
  #   push f.l 1
  # push f.l 2
  # ```
  # Ends up with `[ 0, 'cancel:0_1', 2 ]` in the field `l`.
  #
  # ## on and on_cancel
  #
  # "on_cancel" is made to allow for `on cancel`, so that:
  # ```
  # sequence
  #   on cancel
  #     push f.l msg # a block with a `msg` variable
  #   # ...
  # ```
  # gets turned into:
  # ```
  # sequence
  #   on_cancel
  #     def msg # a anonymous function definition with a `msg` argument
  #       push f.l msg
  #   # ...
  # ```
  #
  #
  # ## see also
  #
  # On, on_error.

  name 'on_cancel'

  def pre_execute

    unatt_unkeyed_children
  end

  def receive_last

    store_on(:cancel)

    ms = super

    ms.first['from_on'] = 'cancel'

    ms
  end
end

