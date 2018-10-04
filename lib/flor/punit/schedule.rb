
class Flor::Pro::Schedule < Flor::Procedure
  #
  # Schedules a function in time.
  #
  # ```
  # schedule cron: '0 0 1 jan *'  # every 1st day of the year, check systems
  #   def msg
  #     check_systems
  # ```
  #
  # It understands `cron:`, `at:`, `in:`, and `every:`.
  #
  # The time string parsing is done by the
  # [fugit](https://github.com/floraison/fugit) gem.
  #
  # ## every:
  #
  # Every understands time durations and, somehow, frequencies.
  #
  # ```
  # every: "5m10s"
  # every: "5 minutes and 10 seconds"
  # ```
  #
  # Fugit translates `every: 'day at five'` into `cron: '0 5 * * *'`.
  #
  # ```
  # every: 'day at five'                  # ==> '0 5 * * *'
  # every: 'weekday at five'              # ==> '0 5 * * 1,2,3,4,5'
  # every: 'day at 5 pm'                  # ==> '0 17 * * *'
  # every: 'tuesday at 5 pm'              # ==> '0 17 * * 2'
  # every: 'wed at 5 pm'                  # ==> '0 17 * * 3'
  # every: 'day at 16:30'                 # ==> '30 16 * * *'
  # every: 'day at noon'                  # ==> '0 12 * * *'
  # every: 'day at midnight'              # ==> '0 0 * * *'
  # every: 'tuesday and monday at 5pm'    # ==> '0 17 * * 1,2'
  # every: 'wed or Monday at 5pm and 11'  # ==> '0 11,17 * * 1,3'
  # ```
  #
  # ## see also
  #
  # Cron, at, in, every, and sleep.

  name 'schedule'

  def pre_execute

    @node['atts'] = []
  end

  def receive_last

    fun = @fcid > 0 ? payload['ret'] : nil

    fail Flor::FlorError.new(
      "missing a function to call when the scheduler triggers", self
    ) unless fun

    m = apply(fun, [], tree[2], anid: false).first

    t, s =
      @node['atts'].find { |k, v| %w[ cron at in every ].include?(k) } ||
      @node['atts'].find { |k, v| k == nil }

    fail Flor::FlorError.new(
      "missing a schedule", self
    ) unless s

    @node['scheduled'] = true

    wrap_schedule('type' => t, 'string' => s, 'message' => m) +
    flank
  end

  def receive

    return [] if @node['scheduled']
    super
  end

  # "schedule" keeps track of its children, but does not cascade 'cancel'
  # to them, unless the cancel flavour is 'kill'.
  #
  def wrap_cancel_children(h={})

    h['flavour'] == 'kill' ? super : []
  end
end


class Flor::Macro::Schedule < Flor::Macro

  def rewrite_schedule_tree(schedule_type)

    atts = att_children
    schedule_i = atts.index { |at| at[1].size == 1 }

    fail Flor::FlorError.new("schedule not found in #{tree.inspect}", self) \
      unless schedule_i

    schedule =
      schedule_type ?
      Flor.dup(atts.delete_at(schedule_i)[1][0]) :
      nil

    l = tree[2]

    th = [ 'schedule', [], l, *tree[3] ]
    th[1] << [ '_att', [ [ schedule_type, [], l ], schedule ], l ] if schedule
    atts.each { |ac| th[1] << Flor.dup(ac) }

    td = [ 'def', [], l ]
    td[1] << [ '_att', [ [ 'msg', [], l ] ], l ]
    non_att_children.each { |nac| td[1] << Flor.dup(nac) }

    th[1] << td

    th
  end
end

