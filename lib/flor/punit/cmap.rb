
class Flor::Pro::Cmap < Flor::Procedure

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

  def determine_iteration_vars(col, idx)

    if col.is_a?(Array)
      { 'elt' => col[idx], 'idx' => idx, 'len' => col.length }
    else
      key, val = col.to_a[idx]
      { 'key' => key, 'val' => val, 'idx' => idx, 'len' => col.length }
    end
  end

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
        vars = determine_iteration_vars(col, i)
        apply(fun, vars.values, tree[2], vars: vars) }
      .flatten(1)
  end

  def receive_ret

    @node['result'] << [ from_sub_nid, payload['ret'] ]
    @node['cnt'] = @node['cnt'] - 1

    return [] if @node['cnt'] > 0 # still waiting for answers

    wrap('ret' => @node['result'].sort_by(&:first).collect(&:last)) # over
  end
end

