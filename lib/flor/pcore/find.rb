
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

