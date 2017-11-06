
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

    fail Flor::FlorError.new("'#{tree[0]}' expects a function", self) \
      unless Flor.is_func_tree?(fun)

    @node['fun'] = fun

    att(nil)
      .collect.with_index { |e, i| apply(fun, [ e, i ], tree[2]) }
      .flatten(1)
  end

  def receive_elt

    snid = Flor.sub_nid(message['from'])
    @node['col'][snid - 1] = payload['ret']

    return [] if cnodes_any?

    payload['ret'] = @node['col']

    wrap
  end
end

