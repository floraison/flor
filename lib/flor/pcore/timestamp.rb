
class Flor::Pro::TimeStamp < Flor::Procedure
  #
  # Places a string timestamp in f.ret.
  #
  # ## timestamp
  #
  # Places the current UTC timestamp into `f.ret`.
  #
  # ```
  # set f.timestamp  # set the field "timestamp" to
  #   timestamp _    # something like "2018-08-13T08:04:06Z"
  # ```
  #
  # ## ltimestamp
  #
  # ```
  # set f.timestamp  # set the field "timestamp" to
  #   ltimestamp _    # something like "2018-08-13T10:04:06"
  # ```

  names %w[ timestamp ltimestamp ]

  def receive_last

    payload['ret'] =
      @node['heat0'][0, 1] == 'l' ?
      Time.now.strftime('%Y-%m-%dT%H:%M:%S') :
      Flor.ststamp

    wrap
  end
end

