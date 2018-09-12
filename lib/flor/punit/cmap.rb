
class Flor::Pro::Cmap < Flor::Procedure

  name 'cmap'

  def pre_execute

    @node['atts'] = []

    @node['fun'] = nil
    @node['col'] = []
  end

  def receive_non_att

    if @node['fun']
      receive_elt
    else
      receive_fun
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

  def receive_fun

    fun = payload['ret']

    fail Flor::FlorError.new("'#{tree[0]}' expects a function", self) \
      unless Flor.is_func_tree?(fun)

    @node['fun'] = fun

    (col = att(nil))
      .collect
      .with_index { |e, i|
        vars = determine_iteration_vars(col, i)
        apply(fun, vars.values, tree[2], vars: vars) }
      .flatten(1)
  end

  def receive_elt

    idx =
      (message['rvars'] && message['rvars']['idx']) ||
      Flor.sub_nid(message['from']) - 1 # fall back :-(

    @node['col'][idx] = payload['ret']

    return [] if cnodes_any?

    payload['ret'] = @node['col']

    wrap
  end
end

