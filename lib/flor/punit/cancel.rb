
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
  # # TODO document "kill"

  name 'cancel', 'kill'
    # ruote had "undo" as well...

  def pre_execute

    @node['atts'] = []
  end

  def receive_last

    targets =
      @node['atts']
        .select { |k, v| k == nil }
        .inject([]) { |a, (k, v)|
          v = Array(v)
          a.concat(v) if v.all? { |e| e.is_a?(String) }
          a } +
      att_a('nid') +
      att_a('ref')

    nids, tags = targets.partition { |t| Flor.is_nid?(t) }

    nids += tags_to_nids(tags)

    fla = @node['heap']

    nids.uniq.map { |nid| wrap_cancel('nid' => nid, 'flavour' => fla)[0] } +
    wrap_reply
  end
end

