
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

  def receive_fun

    fun = payload['ret']

    fail ArgumentError.new(
      "cmap expects a function"
    ) unless Flor.is_func_tree?(fun)

    col = att(nil)
    @node['fun'] = fun

    col.collect.with_index do |e, i|
      apply(@node['fun'], [ e, i ], tree[2])
    end.flatten(1)
  end

  def receive_elt

    @node['col'] << payload['ret']

    return [] if @node['cnodes'].any?

    payload['ret'] = @node['col']

    wrap
  end
end

