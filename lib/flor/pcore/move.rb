
class Flor::Pro::Move < Flor::Procedure
  #
  # Moves a cursor to a given position
  #
  # ```
  # cursor
  #   do-this
  #   move to: 'do-that-other-thing'
  #   do-that _ # got skipped
  #   do-that-other-thing _
  # ```

  name 'move'

  def pre_execute

    @node['atts_accepting_symbols'] = %w[ to ]

    @node['atts'] = []
  end

  def receive_last

    ref = att('ref', nil)
    nid = tags_to_nids(ref).first || @node['heat'][1]['nid']

    to = att('to')

    rep = is_ancestor_node?(nid) ? [] : wrap_reply

    wrap_cancel(
      'nid' => nid,
      'flavour' => @node['heap'], # "move"
      'payload' => rep.any? ? payload.copy_current : payload.current,
      'to' => to) +
    rep
  end
end

