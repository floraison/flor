
class Flor::Pro::Part < Flor::Procedure

  name 'part'
  #names %w[ part flunk flank norep ]

  #                  +-------------------+--------------------+
  #                  | replies to parent | cancellable        |
  # +-------+--------+-------------------+--------------------+
  # | fork  | part   | immediately       | no (not reachable) |
  # |       | flunk  | never             | no (not reachable) |
  # | flank | flank  | immediately       | yes                |
  # | lose  | norep  | never             | yes                |
  # +-------+--------+-------------------+--------------------+
  #
  # reply/r: false, cancellable/c: false

  def receive_last_att

    @node['tree'] = Flor.dup(tree)
    @node['replyto'] = nil

    wrap('flavour' => 'fork', 'nid' => parent, 'ret' => nid) +
    super
  end
end

