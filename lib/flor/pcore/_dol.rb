
class Flor::Pro::Dol < Flor::Procedure

  name '_dol'

  def pre_execute

    t = tree

    @node['on_error'] = [ {
      'point' => 'receive',
      'nid' => nid,
      'from' => Flor.child_nid(nid, 1),
      'payload' => @message['payload'].merge('ret' => '')
    } ]
  end
end

