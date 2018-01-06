
class Flor::Pro::Not < Flor::Procedure
  #
  # `not` negates its last child (or its last unkeyed attribute)
  #
  # ```
  # not _      # --> true
  # not true   # --> false
  # not false  # --> true
  # not 0      # --> false
  # not 1      # --> false
  # ```
  #
  # ```
  # not
  #   true
  #   false  # --> true
  # ```

  name 'not'

  def receive_last

    payload['ret'] = ! Flor.true?(payload['ret'])

    super
  end
end

