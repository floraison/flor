
class Flor::Pro::Part < Flor::Procedure

  names %w[ part flank ]

  #                              +-------------------+--------------------+
  #   ruote           flor       | replies to parent | cancellable        |
  # +-------+-------+------------+-------------------+--------------------+
  # | fork  | part  | part       | immediately       | no (not reachable) |
  # |       | flunk |   r: false | never             | no (not reachable) |
  # | flank | flank | flank      | immediately       | yes                |
  # | lose  | norep |   r: false | never             | yes                |
  # +-------+-------+------------+-------------------+--------------------+
  #
  # reply/r: false, cancellable/c: false
  #
  # to part, to flank, the subject is the diverging branch

  def receive_last_att

    @node['tree'] = Flor.dup(tree)
    @node['replyto'] = nil

    rep, can =
      heap == 'part' ?
      [ true, false ] :
      [ true, true ]
#p att('reply', 'rep', 'r')
#p att('cancellable', 'can', 'c')

    fla = can ? 'flank' : 'part'

    (rep ? wrap('flavour' => fla, 'nid' => parent, 'ret' => nid) : []) +
    super
  end
end

