
# delta.rb

class DeltaTasker

  def initialize(tasker, conf)

    @tasker = tasker
    @conf = conf
  end

  def task(message)

    message['payload']['ret'] = 'dimitri'

    @tasker.reply(message)
  end
end

