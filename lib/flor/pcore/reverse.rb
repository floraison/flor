
class Flor::Pro::Reverse < Flor::Procedure
  #
  # Reverses an array
  #
  # ```
  # reverse [ 0, 2, 4 ]
  #   # --> sets f.ret to [ 4, 2, 0 ]
  # ```
  #
  # Reverses f.ret if there are no arguments
  # ```
  # [ 5, 6, 4 ]
  # reverse _
  #   # --> sets f.ret to [ 4, 6, 5 ]
  # ```

  name 'reverse'

  def receive_last

    if (ret = payload['ret']).respond_to?(:reverse)
      payload['ret'] = ret.reverse
    end

    super
  end
end

