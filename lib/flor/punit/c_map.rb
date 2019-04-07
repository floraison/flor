
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

  protected

  def post_merge

    @node['merged_payload'].merge!(
      'ret' => @node['payloads']
        .sort_by { |k, v| k.split('-').last }
        .collect { |_, v| v['ret'] })
  end
end

