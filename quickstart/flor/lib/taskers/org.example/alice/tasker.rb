
# tasker.rb

class AliceTasker < Flor::BasicTasker

  def task

    payload['alice_tstamp'] = Time.now.to_s

    reply
  end
end

