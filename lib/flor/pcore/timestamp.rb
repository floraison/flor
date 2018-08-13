
class Flor::Pro::TimeStamp < Flor::Procedure
  #
  # Places the current UTC timestamp into `f.ret`.
  #
  # ```
  # set f.timestamp  # set the field "timestamp" to
  #   timestamp _    # something like "2018-08-13T08:04:06Z"
  # ```

  name 'timestamp'

  def receive_last

    wrap('ret' => Flor.ststamp)
  end
end

