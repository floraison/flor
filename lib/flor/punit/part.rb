
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

  def pre_execute

    @node['atts'] = []
  end

  def receive_last_att

    @node['tree'] = Flor.dup(tree)
    @node['replyto'] = nil

    rep = true
    @node['can'] = (heap == 'flank')

    if (r = att('reply', 'rep', 'r')) != nil
      rep = r
    end
    if (c = att('cancellable', 'can', 'c')) != nil
      @node['can'] = c
    end

    fla = @node['can'] ? 'flank' : 'part'
      # so it is possible to have `flank r: true c: false` (iow: `part`)...

    (rep ? wrap('flavour' => fla, 'nid' => parent, 'ret' => nid) : []) +
    super
  end

  def cancel

    # if the node is cancellable, let the cancel messages flow
    # else silence them

    @node['can'] ? super : []
  end
end

