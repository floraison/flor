
require 'flor/pcore/iterator'


class Flor::Pro::Select < Flor::Macro::Iterator
  #
  # Filters a collection
  #
  # ```
  # select [ 1, 2, 3, 4, 5 ]
  #   = (elt % 2) 1
  #
  # # f.ret --> [ 1, 3, 5 ]
  # ```
  #
  # ## with objects (hashes)
  #
  # ```
  # select { a: 'A', b: 'B', c: 'C', d: 'D' }
  #   key == 'a' or val == 'C' or idx == 3
  #
  # # f.ret --> { 'a' => 'A', 'c' => 'C', 'd' => 'D' }
  # ```
  #
  # ## see also
  #
  # filter, map and collect.

  name 'select'

  def rewrite_tree

    rewrite_iterator_tree('filter')
  end
end

