
require 'flor/pcore/_coll'


class Flor::Pro::Obj < Flor::Pro::Coll
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
  end

  def execute_child(index=0, sub=nil, h=nil)

    return super if @node['rets'].size.odd?

    ct = children[index]

    return super unless ct[1] == []

    t = tree
    t[1][index] = [ '_sqs', ct[0], *ct[2..-1] ]
    @node['tree'] = t

    super
  end

  def receive_last_att

    cn = tree[1][@ncid..-1]

    return wrap_object(cn.collect { |c| c[1] }) \
      if cn.all? { |c| atomic?(c) }

    super
  end

  def receive_last

    wrap_object(@node['rets'])
  end

  protected

  def wrap_object(arr)

    wrap_reply(
      'ret' =>
        arr.each_slice(2).inject({}) { |h, (k, v)| h[k.to_s] = v; h })
  end
end

