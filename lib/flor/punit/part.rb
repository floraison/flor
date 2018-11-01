
class Flor::Pro::Part < Flor::Procedure

  names %w[ part flunk flank norep ]

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

    rep, can =
      case heap
      when 'part' then [ true, false ]
      when 'flunk' then [ false, false ]
      when 'flank' then [ true, true ]
      else [ false, true ] # when 'norep'
      end
#p att('reply', 'rep', 'r')
#p att('cancellable', 'can', 'c')

    fla = can ? 'flank' : 'part'

    (rep ? wrap('flavour' => fla, 'nid' => parent, 'ret' => nid) : []) +
    super
  end
end

