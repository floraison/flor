
# Parent class for "c-for-each" and "c-map"
#
class Flor::Pro::ConcurrentIterator < Flor::Procedure

  def pre_execute

    @node['args'] = []
    @node['col'] = nil

    unatt_unkeyed_children
  end

  def receive_non_att

    if @node['col']
      receive_ret
    else
      @node['args'] << payload['ret']
      super
    end
  end

  def receive_last

    if @node['col']
      super
    else
      receive_last_argument
    end
  end

  def add

    col = @node['col']
    elts = message['elements']

    fail Flor::FlorError.new(
      "cannot add branches to #{heap}", self
    ) unless elts

    tcol = Flor.type(col)
    telts = Flor.type(elts)

    fail Flor::FlorError.new(
      "cannot add #{telts} to #{tcol}", self
    ) unless tcol == telts

    if col.is_a?(Array)
      col.concat(elts)
    else
      col.merge!(elts)
    end

    cnt = @node['cnt']
    @node['cnt'] += elts.size

    pl = message['payload'] || node_payload.current

    elts
      .collect
      .with_index { |e, i|
        apply(
          @node['fun'], determine_iteration_args(col, cnt + i), tree[2],
          payload: Flor.dup(pl)) }
      .flatten(1)
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

    @node['col'] = col
    @node['cnt'] = col.size
    @node['fun'] = fun

    col
      .collect
      .with_index { |e, i|
        apply( fun, determine_iteration_args(col, i), tree[2]) }
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
end

