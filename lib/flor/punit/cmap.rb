
require 'flor/punit/citerator'


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

  name 'cmap'

  def pre_execute

    @node['result'] = []

    super
  end

  protected

  def receive_ret

    @node['result'] << [ from_sub_nid, payload['ret'] ]
    @node['cnt'] = @node['cnt'] - 1

    return [] if @node['cnt'] > 0 # still waiting for answers

    wrap('ret' => @node['result'].sort_by(&:first).collect(&:last)) # over
  end
end

