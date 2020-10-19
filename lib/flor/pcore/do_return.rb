# frozen_string_literal: true

class Flor::Pro::DoReturn < Flor::Macro
  #
  # Takes a set of arguments and returns a function
  # that will return those arguments again.
  #
  # ```
  # set a
  #   do-return 1
  # a _
  # ```
  # will set 1 in the payload `ret`.
  #
  # It might be useful in cases like:
  # ```
  # sequence on_error: (do-return 1)
  #   do-this-failure-prone-thing _
  # ```
  #
  # ## see also
  #
  # return

  name 'do-return'

  def rewrite_tree

    l = tree[2]

    [ 'sequence', [
      [ 'def', att_children.first[1], l ]
    ], l ]
  end
end

