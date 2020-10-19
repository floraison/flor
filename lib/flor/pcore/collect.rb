# frozen_string_literal: true

require 'flor/pcore/iterator'


class Flor::Pro::Collect < Flor::Macro::Iterator
  #
  # A simplified version of [map](map.md).
  #
  # ```
  # map [ 1, 2, 3 ]
  #   def x
  #     + x 3
  #   #
  #   # becomes
  #   #
  # collect [ 1, 2, 3 ]
  #   + elt 3
  # ```
  # Collect accepts, instead of a function, a block, where `elt` contains
  # the current element and `idx` the current index.
  #
  # ```
  # collect [ 'a', 'b' ]
  #   [ idx, elt ]
  # ```
  #
  # ## iterating blocks
  #
  # Iterating blocks are given 3 to 4 local variables.
  #
  # A block iterating over an array will receive `elt` (the current element
  # of the iteration), `idx` (the zero-based index of the current element),
  # and `len` (the length of the array).
  #
  # A block iterating over an object will receive `key` (the current string
  # key), `val` (the current value), `idx` (the zero-based index of the
  # current key/val), and `len` (the length of the object).
  #
  # ## see also
  #
  # Map, c-map, c-collect.

  name 'collect'

  def rewrite_tree

    rewrite_iterator_tree('map')
  end
end

