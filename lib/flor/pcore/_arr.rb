
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

  def receive_last

    wrap_reply('ret' => @node['rets'])
  end
end

