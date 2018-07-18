
class Flor::Pro::Dmute < Flor::Procedure

  name '_dmute'

  def pre_execute

    @node['on_error'] = [ {
      'point' => 'receive',
      'nid' => nid,
      'from' => Flor.child_nid(nid, 1),
      'payload' => @message['payload'].merge('ret' => '') } ]
  end
end

