
class Flor::Pro::Break < Flor::Procedure
  #
  # Breaks or continues a "while", "until", "loop" or an "cursor".
  #
  # ```
  # until false
  #   # do something
  #   continue if f.x == 0
  #   break if f.x == 1
  #   # do something more
  # ```
  #
  # ## ref:
  #
  # Break and continue may be used from outside a loop, thanks to the
  # `ref:` attribute:
  #
  # ```
  # set l []
  # concurrence
  #   cursor tag: 'x0'
  #     push l 0
  #     stall _
  #   sequence
  #     push l 1
  #     break ref: 'x0'
  #
  # # where l ends up containing [ 1, 0 ]
  # ```
  #
  # ## "aliasing"
  #
  # A continue or a break may be "aliased", in other words stored in a
  # local variable for reference in a sub-loop.
  #
  # ```
  # cursor
  #   set outer-continue continue
  #   push f.l "$(nid)"
  #   cursor
  #     push f.l "$(nid)"
  #     outer-continue _ if "$(nid)" == '0_2_1_0_0'
  #
  # # where l yields [ '0_1_1', '0_2_0_1', '0_1_1-1', '0_2_0_1-1' ]
  # ```
  #
  # ## see also
  #
  # While, until, loop and cursor.

  name 'break', 'continue'

  def pre_execute

    @node['atts'] = []
  end

  def receive_last

    ref = att('ref')
    nid = tags_to_nids(ref).first || @node['heat'][1]['nid']

    payload['ret'] = att(nil) if has_att?(nil)

    ms = []

    if nid

      ms += wrap_cancel('nid' => nid, 'flavour' => heap)
    end

    unless is_ancestor_node?(nid)

      pl = ms.any? ? payload.copy_current : payload.current
      pl['ret'] = node_payload_ret

      ms += wrap_reply('payload' => pl)
    end

    ms
  end
end

