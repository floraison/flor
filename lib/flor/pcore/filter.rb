
require 'flor/pcore/iterator'


class Flor::Pro::Filter < Flor::Pro::Iterator
  #
  # Filters a collection
  #
  # ```
  # filter [ 1, 2, 3, 4, 5 ]
  #   def x
  #     = (x % 2) 1
  #
  # # f.ret --> [ 1, 3, 5 ]
  # ```
  #
  # ## with objects (hashes)
  #
  # ```
  # filter { a: 'A', b: 'B', c: 'C', d: 'D' }
  #   def k v i
  #     #or (k == 'a') (v == 'C') (i == 3)
  #     k == 'a' or v == 'C' or i == 3
  #
  # # f.ret --> { 'a' => 'A', 'c' => 'C', 'd' => 'D' }
  # ```
  #
  # ## filter-out
  #
  # Is the negative sibling of "filter".
  #
  # ```
  # filter-out [ 1, 2, 3, 4, 5 ]
  #   def x
  #     = (x % 2) 0
  #
  # # f.ret --> [ 1, 3, 5 ]
  # ```
  #
  # ## iterating and functions
  #
  # Iterating functions accept 0 to 3 arguments when iterating over an
  # array and 0 to 4 arguments when iterating over an object.
  #
  # Those arguments are `[ value, index, length ]` for arrays.
  # They are `[ key, value, index, length ]` for objects.
  #
  # The corresponding `key`, `val`, `idx` and `len` variables are also
  # set in the closure for the function call.
  #
  # ## see also
  #
  # map, select, and reject.

  names %w[ filter filter-out ]

  protected

  def receive_iteration

    @node['res'] << @node['col'][@node['idx']] \
      if (
        (heap == 'filter' && Flor.true?(payload['ret'])) ||
        (heap == 'filter-out' && Flor.false?(payload['ret'])))
  end

  def iterator_result

    if @node['ocol'].is_a?(Hash)
      Hash[@node['res']]
    else
      @node['res']
    end
  end
end

