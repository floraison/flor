# frozen_string_literal: true

class Flor::Pro::Echo < Flor::Procedure

  name 'echo'

  def receive_last_att

    case ret = payload['ret']
    when String then puts(ret)
    else pp(ret)
    end

    super
  end

  def receive_last

    payload['ret'] = node_payload_ret

    wrap
  end
end

