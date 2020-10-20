# frozen_string_literal: true

class Flor::Pro::Abort < Flor::Procedure
  #
  # Cancels the current execution.
  #
  # Cancels all the root nodes at once. Is usually the equivalent of
  # `cancel '0'` but sometimes the root nodes are gone...
  #
  # "kabort" is like "abort" but the cancel flavour is 'kill', so that
  # cancel handlers are ignored.
  #
  # ```
  # # ...
  # cursor
  #   task 'prepare mandate'
  #   abort _ if f.outcome == 'reject'
  #   task 'sign mandate'
  # # ...
  # ```
  #
  # ## see also
  #
  # Cancel, kill

  name 'abort', 'kabort'

  def receive_last

    fla = heap == 'kabort' ? 'kill' : 'cancel'

    nodes = @execution['nodes']
    nids = nodes.keys.dup

    @execution['nodes'].values.each do |n|

      #p n.select { |k, v| %w[ nid can parent cnodes ].include?(k) }
      nid = n['nid']
      pa = nodes[n['parent']]

      nids.delete(nid) if pa && pa['cnodes'].include?(nid)
    end

    wrap_cancel_nodes(nids, { 'flavour' => fla })
      .each { |m| m['from'] = '9' }
        # since '9' isn't the parent of any node
  end
end

