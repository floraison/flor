
class Flor::Pro::Sequence < Flor::Procedure
  #
  # Executes child expressions in sequence.
  #
  # ```
  # sequence
  #   task 'alpha'
  #   task 'bravo' if f.amount > 2000
  #   task 'charly'
  # ```
  #
  # Giving a string as attribute result to "sequence" lets it interpret
  # that string as a tag name, as in:
  # ```
  # sequence 'phase one'
  #   alice 'gather customer requirements'
  #   bob 'establish offer'
  # sequence 'phase two'
  #   alice 'present offer to customer'
  #   bob 'sign contract'
  # ```
  # It is equivalent to:
  # ```
  # sequence tag: 'phase one'
  #   alice 'gather customer requirements'
  #   bob 'establish offer'
  # sequence tag: 'phase two'
  #   alice 'present offer to customer'
  #   bob 'sign contract'
  # ```
  # Learn more about [tags](../tags.md).
  #
  # Please note that it sets only 1 tag, and if there are already tags
  # sets (`sequence tags: [ 'a' 'b' ] "this won't become a tag"`), it won't set
  # further tags.
  #
  # ## see also
  #
  # Concurrence, loop

  names %w[ sequence begin ]

  def receive_att

    ms = []

    ms = enter_tag \
      if @node['tags'].nil? && payload_ret.is_a?(String) && from_unkeyed_att?

    ms + super
  end

  def cancel_when_closed

    return cancel if node_status_flavour == 'on-error'

    []
  end

  protected

  def enter_tag

    @node['tags'] = tags = [ payload_ret ]

    wrap('point' => 'entered', 'nid' => nid, 'tags' => tags)
  end
end

