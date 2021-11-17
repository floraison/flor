# frozen_string_literal: true

class Flor::Pro::OnReceive < Flor::Procedure

  name 'on_receive'

  def pre_execute

    unatt_unkeyed_children

    @node['rets'] = []
  end

  def receive_last

    prc = @node['rets'].find { |r| Flor.is_func_tree?(r) }

    store_on(:receive, prc)

    ms = super

    ms.first['from_on'] = 'receive'

    ms
  end
end

