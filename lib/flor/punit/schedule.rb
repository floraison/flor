
class Flor::Pro::Schedule < Flor::Procedure
  #
  # Schedules a function
  #
  # ```
  # schedule cron: '0 0 1 jan *'  # every 1st day of the year, check systems
  #   def msg
  #     check_systems
  # ```
  #
  # See also: cron, at, in and sleep

  name 'schedule'

  def pre_execute

    @node['atts'] = []
  end

  def receive_last

    fun = @fcid > 0 ? payload['ret'] : nil

    fail ArgumentError.new(
      "missing a function to call when the scheduler triggers"
    ) unless fun

    msg =
      apply(fun, [], tree[2], false)
        .first
        .merge('noreply' => true)
          #
          # noreply: true
          #   the applied node will not reply to this, parent, schedule node

    type, string =
      @node['atts'].find { |k, v| %w[ cron at in every ].include?(k) } ||
      @node['atts'].find { |k, v| k == nil }

    fail ArgumentError.new(
      "missing a schedule"
    ) unless string

    schedule('type' => type, 'string' => string, 'message' => msg)
  end

  def cancel

    super + reply('payload' => node_payload.current)
  end
end

