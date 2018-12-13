
class Flor::Pro::Cmap < Flor::Procedure
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

    @node['args'] = []
    @node['result'] = nil

    unatt_unkeyed_children
  end

  def receive_non_att

    if @node['result']
      receive_ret
    else
      @node['args'] << payload['ret']
      super
    end
  end

  def receive_last

    if @node['result']
      super
    else
      receive_last_argument
    end
  end

  protected

  def receive_last_argument

    col = nil
    fun = nil
    @node['args'].each do |a|
      if Flor.is_func_tree?(a)
        fun = a
      elsif Flor.is_collection?(a)
        col = a
      end
    end
    col ||= node_payload_ret

    fail Flor::FlorError.new("collection not given to #{heap.inspect}", self) \
      unless Flor.is_collection?(col)
    return wrap('ret' => col) \
      unless Flor.is_func_tree?(fun)

    @node['cnt'] = col.size
    @node['result'] = []

    col
      .collect
      .with_index { |e, i|
        apply(fun, determine_iteration_args(col, i), tree[2]) }
      .flatten(1)
  end

  def determine_iteration_args(col, idx)

    args =
      if col.is_a?(Array)
        [ [ 'elt', col[idx] ] ]
      else
        e = col.to_a[idx]
        [ [ 'key', e[0] ], [ 'val', e[1] ] ]
      end
    args << [ 'idx', idx ]
    args << [ 'len', col.length ]

    args
  end

  def receive_ret

    @node['result'] << [ from_sub_nid, payload['ret'] ]
    @node['cnt'] = @node['cnt'] - 1

    return [] if @node['cnt'] > 0 # still waiting for answers

    wrap('ret' => @node['result'].sort_by(&:first).collect(&:last)) # over
  end
end

