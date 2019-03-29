
# tasker.rb

class BobTasker < Flor::BasicTasker

  def task

    payload['bob_tstamp'] = Time.now.to_s

    reply
  end
end

