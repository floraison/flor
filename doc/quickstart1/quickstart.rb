
# This example code is released under the MIT license, see ../LICENSE.txt

require 'flor/unit'

FLOR = Flor::Unit.new('flor/etc/conf.json')
  # Configuration is all there
  # It points DB to flor/var/flor.db
  # Binds this flor unit instances behind the `FLOR` name

FLOR.storage.delete_tables
FLOR.storage.migrate
  # Prepare fresh database

FLOR.start
  # Start the flor unit
  # That starts a thread ticking for messages (launch messages, tasker replies,
  # etc)

msg = FLOR.launch('org.example.flow0', wait: true)
  # Launches the flow at flor/lib/flows/org.example/flow0.flor
  # There is more information about domain: and wait: at ../doc/launching.md

sleep 0.5
  # Give time to executor to shutdown and stop spitting debug info

puts
puts 'final message:'
pp msg
  # Pretty print the "terminated" message (could be a "failed" message if
  # something went wrong)

#FLOR.join
  #
  # Commented out but shows how to join the scheduler's thread and
  # not exit directly.
  # Such a #join call is necessary only when one sets up a Ruby process
  # dedicated to a flor scheduler.

