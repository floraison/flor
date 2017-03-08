
# This example code is released under the MIT license, see ../LICENSE.txt

require 'flor/unit'

FLOR = Flor::Unit.new('flor/etc/conf.json')
  # configuration is all there

FLOR.storage.delete_tables
FLOR.storage.migrate
FLOR.start
  # prepare fresh database

msg =
  FLOR.launch(
    %{
      concurrence
        alice _
        bob _
    },
    domain: 'org.example',
    wait: true)
  # launch a simple flow fanning work to alice and bob

sleep 0.5
  # give time to executor to shutdown and stop spitting debug info

pp msg

#FLOR.join

