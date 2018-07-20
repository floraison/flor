
class Flor::Pro::Dol < Flor::Procedure

  name '_dol'

  def receive

    return super unless @message['point'] == 'receive'

    determine_fcid_and_ncid

    ncnid = Flor.child_nid(nid, @ncid)
    ntree = lookup_tree(ncnid)

    case ntree && ntree[0]
    when '_dor' then hand_to_dor
    when '_dpipe' then hand_to_dpipe
    else super
    end
  end

  protected

  def hand_to_dor

    ret = payload['ret']

    return receive_non_att \
      if (ret.is_a?(String) && ret.length == 0) || ret == false

    wrap
  end
end

