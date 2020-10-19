# frozen_string_literal: true

require 'flor/pcore/_pat_'


class Flor::Pro::PatRegex < Flor::Pro::PatContainer

  name '_pat_regex'

  def pre_execute

    @node['rets'] = []
    @node['atts'] = []
  end

  def execute_child(index=0, sub=nil, h=nil)

    payload['ret'] = node_payload_ret
      # always pass the noe_payload_ret to children

    super
  end

  def receive_last

    return wrap_no_match_reply unless val.is_a?(String)

    rex = Flor.to_regex(@node['rets'] + [ att('rxopts') ])
    m = rex.match(val)

    return wrap_no_match_reply unless m

    payload['_pat_binding'] = { 'matched' => val, 'match' => m.to_a }
    payload.delete('_pat_val')

    wrap_reply
  end
end

