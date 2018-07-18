
class Flor::Pro::Dol < Flor::Procedure

  name '_dol'

  def pre_execute

    t = tree

    @node['on_error'] = [ {
      'point' => 'receive',
      'nid' => nid,
      'from' => Flor.child_nid(nid, 1),
      'payload' => @message['payload'].merge('ret' => '') } ]
  end

#  def receive
#
#    determine_fcid_and_ncid
#
#p Flor.child_nid(nid, @ncid)
#    #ntree = lookup_tree(
#
#pp @message
#p [ @fcid, @ncid ]
#    super
#  end
end

