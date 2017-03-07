
class Flor::Pro::Graft < Flor::Procedure
  #
  # Graft a subtree into the current flo
  #
  # Given
  # ```
  # # sub0.flo
  # sequence
  #   task 'a'
  #   task 'b'
  # ```
  # and
  # ```
  # # sub1.flo
  # sequence
  #   task 'c'
  #   task 'd'
  # ```
  # then
  # ```
  # # main.flo
  # concurrence
  #   graft 'sub0.flo'
  #   graft 'sub1' # suffix can be omitted
  #   graft 'sub0'
  #     #
  #     # which is thus equivalent to
  #     #
  # concurrence
  #   sequence
  #     task 'a'
  #     task 'b'
  #   sequence
  #     task 'c'
  #     task 'd'
  #   sequence
  #     task 'a'
  #     task 'b'
  # ```

  names 'graft', 'import'

  def pre_execute

    @node['execute_message'] = Flor.dup(@message)
    @node['atts'] = []
  end

  def receive_last

    # look up subtree

    sub =
      att('tree', 'subtree', 'flow', 'subflow', 'twig', nil)
    source_path, source =
      @executor.unit.loader.library(domain, sub, subflows: true)

    fail ArgumentError.new(
      "no subtree #{sub.inspect} found (domain #{domain.inspect})"
    ) unless source

    tree = Flor::Lang.parse(source, source_path, {})

    # graft subtree into parent node

    parent_tree = lookup_tree(parent)
    cid = Flor.child_id(nid)
    parent_tree[1][cid] = tree

    # re-apply self with subtree

    m = @node['execute_message']
    m['tree'] = tree

    [ m ]
  end
end

