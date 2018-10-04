
class Flor::Pro::NoRet < Flor::Procedure
  #
  # Executes its children, but doesn't alter the received f.ret
  #
  # ```
  # sequence
  #   123
  #   noret
  #     456
  #   # f.ret is "back" to 123 at this point
  # ```

  name 'noret'

  def receive_last

    payload['ret'] = node_payload_ret

    wrap
  end
end

