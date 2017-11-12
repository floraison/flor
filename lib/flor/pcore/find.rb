
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
  # ## see also
  #
  # map and detect.

  name 'find'

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

