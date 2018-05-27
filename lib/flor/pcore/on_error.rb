
class Flor::Pro::OnError < Flor::Procedure
  #
  # Counterpart to the on_error: attribute.
  #
  # Takes a function definition (or a variable pointing to one of them)
  # and makes sure the function is called when an error occurs at the
  # current level or below.
  #
  # ```
  # sequence
  #   set f.l []
  #   on_error (def err \ push f.l err.error.msg)
  #   push f.l 0
  #   push f.l x # <-- will fail because `x` is unknown
  #   push f.l 1
  # ```
  # Where the field `l` ends up containing
  # `[ 0, "don't know how to apply \"x\"" ]`.
  #
  # ```
  # set f.l []
  #
  # define error_handler err
  #   push f.l err.error.msg
  #
  # sequence
  #   on_error error_handler
  #   # ...
  # ```
  #
  # ## on and on_error
  #
  # "on_error" is made to allow for `on error`, so that:
  # ```
  # sequence
  #   on error
  #     push f.l err.msg # a block with an `err` variable
  #   # ...
  # ```
  # gets turned into:
  # ```
  # sequence
  #   on_error
  #     def err # a anonymous function definition with an `err` argument
  #       push f.l err.msg
  #   # ...
  # ```
  #
  # ## see also
  #
  # On.

  name 'on_error'

  def pre_execute

    unatt_unkeyed_children
  end

  def receive_non_att

    store_on(:error)

    super
  end
end

