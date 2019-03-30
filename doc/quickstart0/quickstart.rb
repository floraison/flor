
require 'flor/unit'

#ENV['FLOR_DEBUG'] = 'dbg,sto,stdout'
#ENV['FLOR_DEBUG'] = 'dbg,stdout'

sto_uri =
  RUBY_PLATFORM.match(/java/) ?
  'jdbc:sqlite://quickstart.db' :
  'sqlite://quickstart.db'

flor = Flor::Unit.new(
  loader: Flor::HashLoader,
  sto_uri: sto_uri)

flor.storage.delete_tables
flor.storage.migrate

class AliceTasker < Flor::BasicTasker
  def task(message)
    message['payload']['msg'] = 'hello'
    reply
  end
end
class BobTasker < Flor::BasicTasker
  def task(message)
    message['payload']['msg'] += ' world'
    reply
  end
end

flor.add_tasker(:alice, AliceTasker)
flor.add_tasker(:bob, BobTasker)

flor.start

exid = flor.launch(%q{
    sequence
      alice _
      bob _
  })

r = flor.wait(exid, 'terminated')

p r['payload']['msg']

