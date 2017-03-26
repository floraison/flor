
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

    m = apply(fun, [], tree[2], false).first

    t, s =
      @node['atts'].find { |k, v| %w[ cron at in every ].include?(k) } ||
      @node['atts'].find { |k, v| k == nil }

    bi = parent || '0' # bound to nid

    fail ArgumentError.new(
      "missing a schedule"
    ) unless s

    @node['scheduled'] = true

    wrap_schedule('type' => t, 'string' => s, 'bnid' => bi, 'message' => m)
  end

  def receive

    return [] if @node['scheduled']
    super
  end

  def cancel

    super + wrap_reply('payload' => node_payload.current)
  end
end

