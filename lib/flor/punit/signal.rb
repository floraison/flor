
class Flor::Pro::Signal < Flor::Procedure
  #
  # Used in conjuction with "on".
  #
  # An external (or internal) agent may send a signal to an execution and the
  # execution may have a "on" handler for it.
  #
  # For example, imagine an execution with a sub part that checks every day
  # at noon and closes cases that are over a certain date:
  #
  # ```
  # on 'close'
  #   # close the case and then cancel main part...
  #   cancel ref: 'main'
  #
  # every 'day at noon'
  #   signal 'close' if f.date_to < today
  #
  # sequence tag: 'main'
  #   # main part ...
  # ```
  #
  # The "every day at noon" sub part could be replaced by a signal emitted by
  # a Ruby script triggered by a cron daemon, thus going from internal agent
  # to external agent.
  #
  # The `Flor::Unit` class has a `#signal` method handy for that:
  # ```ruby
  # flor_unit.signal('close', exid: execution_id)
  # ```
  # It accepts `exid:` and `payload:` messages.
  #
  # ## signal payloads
  #
  # The payload at the point of signalling is transmitted over to the
  # receiving "on" or "trap".
  #
  # ```
  # set f.a 'A'
  # signal 'close'
  #   set f.b 'B'
  #   [ 0 1 2 ]
  # set f.c 'C'
  # ```
  # passes `{ 'ret' => [ 0, 1, 2 ], 'a' => 'A', 'b' => 'B' }` as payload
  # to any intercepting "on" or "trap" (`c` is not passed).
  #
  # Externally, you can signal with a specific payload thanks to:
  # ```ruby
  # flor_unit.signal('close', exid: execution_id, payload: { 'f0' => 'zero' })
  # ```
  #
  # ## see also
  #
  # On and trap.

  name 'signal'

  def pre_execute

    @node['atts'] = []
  end

  def receive_last

    name = att('name', nil)

    return super unless name

    wrap(
      'point' => 'signal', 'nid' => nid, 'name' => name,
      'payload' => payload.copy_current
    ) + super
  end
end

