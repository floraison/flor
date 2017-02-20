
class Flor::Pro::Obj < Flor::Procedure

  name '_obj'

  def pre_execute

    @node['rets'] = []
  end

  def receive_first

    return reply('ret' => {}) if children == 0

    cn = children
      .inject([]) { |a, e| a << (a.size.even? ? stringify(e) : e); a }

    @node['tree'] = [ tree[0], cn, tree[2] ] if children != cn

    super
  end

  def receive_last

    payload['ret'] =
      @node['rets']
        .each_slice(2)
        .inject({}) { |h, (k, v)| h[k.to_s] = v; h }

    reply
  end

  protected

  def stringify(t)

    return t unless t[1] == [] && t[0].is_a?(String)
    [ '_sqs', deref(t[0]) || t[0], t[2] ]
  end
end

