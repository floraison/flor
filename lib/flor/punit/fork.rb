
class Flor::Pro::Fork < Flor::Procedure

  name 'fork'

  #                         +-------------------+--------------------+
  #                         | replies to parent | cancellable        |
  # +-----------------------+-------------------+--------------------+
  # | fork, forget, fire    | immediately       | no (not reachable) |
  # | lose                  | never             | yes                |
  # | flank (o)             | immediately       | yes                |
  # | xxx                   | never             | no (not reachable) |
  # +-----------------------+-------------------+--------------------+

  def receive_last_att

    @node['tree'] = Flor.dup(tree)
    @node['replyto'] = nil

    ms = super
    nid = ms.any? ? ms.first['nid'] : nil
p nid

    wrap('flavour' => 'fork', 'nid' => parent, 'ret' => nid) +
    ms
  end
end

