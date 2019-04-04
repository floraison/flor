
require 'flor/punit/c_iterator'


class Flor::Pro::Cmap < Flor::Pro::ConcurrentIterator
  #
  # Concurrent version of "map". Spins a concurrent child for each
  # element of the incoming/argument collection.
  #
  # ```
  # cmap [ 1 2 3 ]
  #   def x \ * x 2
  # # yields: [ 2, 4, 6 ]
  #
  # [ 1 2 3 ]
  # cmap (def x \ * x 2)
  # # yields: [ 2, 4, 6 ]
  #
  # define double x \ * x 2
  # cmap double [ 1 2 3 ]
  # # yields: [ 2, 4, 6 ]
  # ```
  #
  # "cmap" is over when all the children have answered. For more complex
  # concurrent behaviours, look at [concurrence](concurrence.md).
  #
  # ## see also
  #
  # Map, concurrence.

  names %w[ cmap c-map ]

  def pre_execute

    @node['result'] = []

    super
  end

  protected

  def receive_ret

    @node['result'] << [ from_sub_nid, payload['ret'] ]

    if (@node['cnt'] -= 1) > 0 # still waiting for answers
      []
    else # over
      wrap('ret' => @node['result'].sort_by(&:first).collect(&:last))
    end
  end
end

