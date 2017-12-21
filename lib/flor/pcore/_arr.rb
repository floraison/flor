
class Flor::Pro::Arr < Flor::Procedure
  #
  # "_arr" is the procedure behind arrays.
  #
  # Writing
  # ```
  # [ 1 2 3 ]
  # ```
  # is in fact read as
  # ```
  # _arr
  #   1
  #   2
  #   3
  # ```
  # by flor.

  name '_arr'

  def receive_last_att

    elts = tree[1][@ncid..-1]

    return wrap_reply('ret' => elts.collect { |e| e[1] }) \
      if elts.all? { |e|
        e0, e1 = *e
        ( ! e1.is_a?(Array)) &&
        (e0 != '_sqs' || ! e1.index('$(')) &&
        e0 != '_rxs' &&
        e0 != '_func' &&
        Flor::Pro::Atom.names.include?(e0) }

    @node['rets'] = []
    super
  end

  def receive_last

    wrap_reply('ret' => @node['rets'])
  end
end

