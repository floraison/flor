
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
  # ## see also
  #
  # Concurrence, loop

  names %w[ sequence begin ]

  def receive_att

    ms = []

    if
      @node['tags'].nil? &&
      payload_ret.is_a?(String) &&
      tree[1][@fcid][1].size == 1
    then
      ms = enter_tag
    end

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

