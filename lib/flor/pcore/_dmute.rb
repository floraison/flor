# frozen_string_literal: true

class Flor::Pro::Dmute < Flor::Procedure

  name '_dmute'

  def pre_execute

    @node['on_error'] = [
      [ [ '*' ],
        { 'point' => 'receive',
          'nid' => nid,
          'from' => Flor.child_nid(nid, 999 + tree[1].size),
            # "#{nid}_#{999 + child.count}"
          'exid' => exid,
          'force_payload' => @message['payload'].merge('ret' => '') } ] ]
            #
            # using 'force_payload' to tell Procedure#pop_on_receive_last
            # to use this payload
  end
end

