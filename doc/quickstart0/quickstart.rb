
require 'flor/unit'

#ENV['FLOR_DEBUG'] = 'dbg,sto,stdout' # full sql + flor debug output
#ENV['FLOR_DEBUG'] = 'dbg,stdout' # flor debug output
  # uncomment to see the flor activity

sto_uri = 'sqlite://flor_qs.db'
sto_uri = 'jdbc:sqlite://flor_qs.db' if RUBY_PLATFORM.match(/java/)

flor = Flor::Unit.new(loader: Flor::HashLoader, sto_uri: sto_uri)
  # instantiate flor unit

flor.storage.delete_tables
flor.storage.migrate
  # blank slate database

class DemoTasker < Flor::BasicTasker
  def task(message)
    (attd['times'] || 1).times do
      message['payload']['log'] << "#{tasker}: #{task_name}"
    end
    reply
  end
end
flor.add_tasker(:alice, DemoTasker)
flor.add_tasker(:bob, DemoTasker)
  # a simple logging tasker implementation bound under
  # two different tasker names

flor.start
  # start the flor unit, so that it can process executions

exid = flor.launch(
  %q{
    sequence
      alice 'hello' times: 2
      bob 'world'
  },
  payload: { log: [ "started at #{Time.now}" ] })
    # launch a new execution, one that chains alice and bob work

#r = flor.wait(exid, 'terminated')
r = flor.wait(exid)
  # wait for the execution to terminate or to fail

p r['point']
  # "terminated" hopefully
p r['payload']['log']
  # [ "started at 2019-03-31 10:20:18 +0900",
  #   "alice: hello", "alice: hello",
  #   "bob: world" ]

