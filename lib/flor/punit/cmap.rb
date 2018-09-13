
class Flor::Pro::Cmap < Flor::Procedure

  name 'cmap'

  def pre_execute

    @node['args'] = []
    @node['result'] = nil

    unatt_unkeyed_children
  end

  def receive_non_att

    @node['args'] << payload['ret']

    super
  end

  def receive_last

    if @node['result']
      receive_ret
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

    fail Flor::FlorError.new("function not given to #{heap.inspect}", self) \
      unless Flor.is_func_tree?(fun)
    fail Flor::FlorError.new("collection not given to #{heap.inspect}", self) \
      unless Flor.is_collection?(col)

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

    i = from.split('-').last.to_i - 1

    @node['result'][i] = payload['ret']
    @node['cnt'] = @node['cnt'] - 1

    if @node['cnt'] < 1
      wrap('ret' => @node['result']) # over
    else
      [] # still waiting for answers
    end
  end
end

