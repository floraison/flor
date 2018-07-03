
class Flor::Pro::Twig < Flor::Procedure

  name 'twig'

  def pre_execute

    unatt_unkeyed_children
    rep_first_child
  end

  def receive_first

    nac = non_att_children

    if nac.size == 1
      wrap_reply('ret' => nac.first)
    else
      super
    end
  end

  def receive_non_att

    t = non_att_children.last

    set_value(payload['ret'], t)

    wrap
  end
end

