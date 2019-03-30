
# bob.rb


## tasker implementation

class BobTasker < Flor::BasicTasker

  def task

    payload['bob_tstamp'] = Time.now.to_s

    reply
  end
end


## tasker configuration

{
  class: 'BobTasker'
}

