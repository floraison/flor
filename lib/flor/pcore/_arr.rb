
class Flor::Pro::Arr < Flor::Procedure
  #
  # "_arr" is the procedure behind arrays.
  #
  # Writing
  # ```
  # [ 1 2 3 ]
  # ```
  # is in fact read as
  # ```
  # _arr
  #   1
  #   2
  #   3
  # ```
  # by flor.

  name '_arr'

  def pre_execute

    @node['rets'] = []
  end

  def receive

    return wrap_reply('ret' => []) if children == 0

    super
  end

  def receive_last

    payload['ret'] = @node['rets']

    wrap_reply
  end
end

