
class Flor::Pro::Obj < Flor::Procedure
  #
  # "_obj" is the procedure behind objects (maps).
  #
  # Writing
  # ```
  # { a: 1, b: 2 }
  # ```
  # is in fact read as
  # ```
  # _obj
  #   'a'
  #   1
  #   'b'
  #   2
  # ```
  # by flor.

  name '_obj'

  def pre_execute

    @node['rets'] = []
    @node['atts'] = []
  end

  def receive_last_att

    return super unless att('quote') == 'keys'

    t0 = tree
    t1 = Flor.dup(t0)

    (@ncid..t1[1].length - 1).step(2) do |i|

      c = t1[1][i]

      t1[1][i] = [ '_sqs', c[0], *c[2..-1] ] if c[0].is_a?(String) && c[1] == []
    end

    @node['tree'] = t1 if t1 != t0

    super
  end

  def receive_first

    return wrap_reply('ret' => {}) if children == 0

    cn = children
      .inject([]) { |a, e|
        a << (a.size.even? ? deref_and_stringify(e) : e)
        a }

    @node['tree'] = [ tree[0], cn, *tree[2..-1] ] if children != cn

    super
  end

  def receive_last

    payload['ret'] = @node['rets']
      .each_slice(2)
      .inject({}) { |h, (k, v)| h[k.to_s] = v; h }

    wrap_reply
  end

  protected

  def deref_and_stringify(t)

    return t unless t[1] == [] && t[0].is_a?(String)
    [ '_sqs', deref(t[0]) || t[0], t[2] ]
  end
end

