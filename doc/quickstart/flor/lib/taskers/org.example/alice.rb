
# alice.rb


## tasker implementation

class AliceTasker < Flor::BasicTasker

  def task

    payload['alice_tstamp'] = Time.now.to_s

    reply
  end
end


## tasker configuration

{
  class: 'AliceTasker'
}

