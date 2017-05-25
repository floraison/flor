
class Flor::Pro::PatOr < Flor::Pro::PatContainer

  name '_pat_or'

  def receive_non_att

    ct = child_type(@fcid)

    if ct == :pattern

# TODO!

    elsif payload['ret'] == val

      return wrap_match_reply
    end

    super
  end

  def receive_last

    wrap_no_match_reply
  end

  protected

  def wrap_match_reply

    payload['_pat_binding'] = {}
    payload.delete('_pat_val')

    wrap_reply
  end
end

