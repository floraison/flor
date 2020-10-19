# frozen_string_literal: true

require 'flor/pcore/_coll'


class Flor::Pro::Arr < Flor::Pro::Coll
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
      if elts.all? { |e| atomic?(e) }

    @node['rets'] = []
    super
  end

  def receive_last

    wrap_reply('ret' => @node['rets'])
  end
end

