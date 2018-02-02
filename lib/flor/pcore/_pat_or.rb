
require 'flor/pcore/_pat_'


class Flor::Pro::PatOr < Flor::Pro::PatContainer

  name '_pat_or'

  def pre_execute

    unatt_unkeyed_children
  end

  def receive_non_att

    ct = child_type(@fcid)

    if ct == :pattern

      b = payload.delete('_pat_binding')
      return wrap_match_reply(b) if b

    elsif ct == '_' && val != '_'

      return wrap_no_match_reply

    elsif payload['ret'] == val

      return wrap_match_reply({})
    end

    super
  end

  def receive_last

    wrap_no_match_reply
  end

  protected

  def wrap_match_reply(binding)

    payload['_pat_binding'] = binding
    payload.delete('_pat_val')

    wrap_reply
  end
end

