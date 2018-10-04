
require 'flor/pcore/iterator'


class Flor::Pro::Inject < Flor::Macro::Iterator
  #
  # A simplified version of [reduce](reduce.md).
  #
  # Inject takes a collection and a block. It reduces the collection
  # to a single result thanks to the block.
  #
  # The block is run for each element in the collection, it's passed
  # `res` and `elt`. `res` is the result, the accumulator, `elt`
  # is the current element in the collection.
  #
  # The block must return the result for the next iteration.
  #
  # ```
  # inject [ '0', 1, 'b', 3 ]
  #   res + elt
  # # --> "01b3"
  # ```
  #
  # An initial value is accepted (generally after the collection)
  #
  # ```
  # inject [ 0, 1, 2, 3, 4 ] 10
  #   res + elt
  # # --> 20
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
  # Reduce.

  name 'inject'

  def rewrite_tree

    rewrite_iterator_tree('reduce')
  end
end

