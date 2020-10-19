# frozen_string_literal: true

class Flor::Pro::Cancel < Flor::Procedure
  #
  # Cancels an execution branch
  #
  # ```
  # concurrence
  #   sequence tag: 'blue'
  #   sequence
  #     cancel ref: 'blue'
  # ```
  # You can drop the `ref:`
  # ```
  # concurrence
  #   sequence tag: 'blue'
  #   sequence
  #     cancel 'blue'
  # ```
  #
  # It's also OK to use nids directly:
  # ```
  # concurrence         # 0
  #   sequence          # 0_0
  #     # ...
  #   sequence          # 0_1
  #     cancel nid: '0_0'
  #       # or
  #     #cancel '0_0'
  # ```
  # But it's kind of brittle compared to using tags.
  #
  # ## kill
  #
  # "kill" is equivalent to "cancel", but once called, cancel handlers are
  # ignored, it cancels through.
  #
  #
  # ## see also
  #
  # On_cancel, on

  name 'cancel', 'kill'
    # ruote had "undo" as well...

  def pre_execute

    @node['atts'] = []
  end

  def receive_last

    targets =
      @node['atts']
        .select { |k, _| k == nil }
        .inject([]) { |a, (_, v)|
          v = Array(v)
          a.concat(v) if v.all? { |e| e.is_a?(String) }
          a } +
      att_a('nid') +
      att_a('ref')

    nids, tags = targets.partition { |t| Flor.is_nid?(t) }
    nids += tags_to_nids(tags)
    nids = nids.uniq

    fla = heap

    messages = nids
      .collect { |nid| wrap_cancel('nid' => nid, 'flavour' => fla)[0] }

    messages = messages + wrap_reply \
      unless nids.find { |nid| is_ancestor_node?(nid) }

    messages
  end
end

