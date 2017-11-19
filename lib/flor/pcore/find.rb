
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
  # map and detect.

  name 'find'

  protected

  def pre_iterator

    # nothing to do
  end

  def receive_iteration

    # nothing to do
  end

  def iterator_over?

    @node['idx'] > 0 && Flor.true?(payload['ret'])
  end

  def iterator_result

    @node['col'][@node['idx'] - 1]
  end
end

