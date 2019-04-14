
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
  # ## signalling another execution
  #
  # If the exid of execution A is known in execution B, execution B can
  # send a signal to A.
  #
  # ```ruby
  # exid0 = @unit.launch(
  #   %q{
  #     trap signal: 'green' # block until receiving the 'green' signal
  #     set f.done true
  #   })
  # @unit.launch(
  #   %q{
  #     set f.a 'a'
  #     signal exid: f.exid0 'green' # send 'green' signal to exid0
  #     set f.b 'b'
  #   },
  #   payload: { 'exid0' => exid0 })
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

    na = att('name', nil)
    ei = att('exid') || exid
    pl = att('payload') || payload.copy_current

    return super unless na

    wrap(
      'point' => 'signal',
      'exid' => ei, 'nid' => nid,
      'name' => na, 'payload' => pl
    ) +
    super
  end
end

