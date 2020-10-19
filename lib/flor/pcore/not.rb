# frozen_string_literal: true

class Flor::Pro::Not < Flor::Procedure
  #
  # Negates its last child (or its last unkeyed attribute)
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
  #
  # ```
  # not true false  # --> true
  # ```
  #
  # ## Warning
  #
  # ```
  # and not(false) not(false)  # --> false
  # ```
  # It is recommended to use:
  # ```
  # and (not false) (not false)  # --> true
  # ```

  name 'not'

  def receive_last

    payload['ret'] = ! Flor.true?(payload['ret'])

    super
  end
end

