
class Flor::Pro::Cron < Flor::Macro
  #
  # "cron" is a macro procedure.
  #
  # ```
  # cron: '0 0 1 jan *'
  #   task albert 'take out garbage'
  # ```
  #
  # is automatically turned into:
  #
  # ```
  # schedule cron: '0 0 1 jan *'
  #   def msg
  #     task albert 'take out garbage'
  # ```

  name 'cron'

    # TODO for "on", "cron", "at", "in" and "every"
    #      have a simpler #rewrite_tree
    #
  def rewrite_tree

    atts = att_children
    schedule_i = atts.index { |at| at[1].size == 1 }

    fail ArgumentError.new(
      "schedule not found in #{tree.inspect}"
    ) unless schedule_i

    schedule = atts[schedule_i]
    schedule = Flor.dup(schedule[1][0])
    atts.delete_at(schedule_i)

    l = tree[2]

    th = [ 'schedule', [], l, *tree[3] ]
    th[1] << [ '_att', [ [ 'cron', [], l ], schedule ], l ]
    atts.each { |ac| th[1] << Flor.dup(ac) }

    td = [ 'def', [], l ]
    td[1] << [ '_att', [ [ 'msg', [], l ] ], l ]
    non_att_children.each { |nac| td[1] << Flor.dup(nac) }

    th[1] << td

    th
  end
end

