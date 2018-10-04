
require 'flor/punit/schedule'


class Flor::Pro::Cron < Flor::Macro::Schedule
  #
  # A macro-procedure, rewriting itself to `schedule cron: ...`.
  #
  # ```
  # cron '0 0 1 jan *'
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
  #
  # ## see also
  #
  # Schedule, and every.

  name 'cron'

  def rewrite_tree

    rewrite_schedule_tree('cron')
  end
end

