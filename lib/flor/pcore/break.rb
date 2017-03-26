
class Flor::Pro::Break < Flor::Procedure
  #
  # Breaks or continues a "while" or "until".
  #
  # ```
  # until false
  #   # do something
  #   continue if f.x == 0
  #   break if f.x == 1
  #   # do something more
  # ```

  name 'break', 'continue'

  def pre_execute

    @node['atts'] = []
  end

  def receive_last

    ref = att('ref')
    nid = tags_to_nids(ref).first || @node['heat'][1]['nid']
#p [ :break, @node['heap'], nid ]

    payload['ret'] = att(nil) if has_att?(nil)

    ms = []

    if nid

      ms += wrap_cancel('nid' => nid, 'flavour' => @node['heap'])
    end

    unless is_ancestor_node?(nid)

      pl = ms.any? ? payload.copy_current : payload.current
      pl['ret'] = node_payload_ret

      ms += wrap_reply('payload' => pl)
    end

    ms
  end
end

