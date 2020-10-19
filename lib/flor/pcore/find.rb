# frozen_string_literal: true

require 'flor/pcore/iterator'


class Flor::Pro::Find < Flor::Pro::Iterator
  #
  # Finds the first matching element.
  #
  # ```
  # find [ 1, 2, 3 ]
  #   def elt
  #     (elt % 2) == 0
  # # f.ret --> 2
  # ```
  #
  # With objects (maps), it returns the first matching entry (pair).
  # ```
  # find { a: 'A', b: 'B', c: 'C' }
  #   def key, val
  #     val == 'B'
  # # f.ret --> [ 'b', 'B' ]
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
  # Map and detect, any?.

  name 'find'

  protected

  def pre_iterator

    # nothing to do
  end

  def receive_iteration

    # nothing to do
  end

  def iterator_over?

    super || (@node['idx'] > 0 && Flor.true?(payload['ret']))
  end

  def iterator_result

    if Flor.true?(payload['ret'])
      @node['col'][@node['idx'] - 1]
    else
      nil
    end
  end
end

