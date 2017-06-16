
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

msg =
  FLOR.launch(
    %q{
      concurrence     #
        alice _       # the "workflow definition",
        bob _         # the 'program' that flor interprets
    },
    domain: 'org.example',
    wait: true)
      #
      # Launch a simple flow handing work tasks to alice and bob concurrently
      # "concurrence" will wait for alice and bob to reply
      # `wait: true` tells the #launch to wait for the flow to end
      # The flow will end when its root procedure ("concurrence" here) ends
      #
      # "alice" and "bob" are 'taskers', their implementations can be found
      # under quickstart/flor/lib/taskers/org.example/alice/ and
      # quickstart/flor/lib/taskers/org.example/bob/ respectively

sleep 0.5
  # Give time to executor to shutdown and stop spitting debug info

pp msg
  # Pretty print the "terminated" message (could be a "failed" message if
  # something went wrong)

#FLOR.join

