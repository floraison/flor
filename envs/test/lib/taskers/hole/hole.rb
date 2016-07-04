
# hole.rb

class HoleTasker

  def initialize(tasker, conf)

    @tasker = tasker
  end

  def task(message)

    @@message = Flor.dup(message)
    # do nothing
  end

  def cancel(message)

    (message['payload'] ||= {})['holed'] = @@message
    @@message = nil

    @tasker.reply(message)
  end

  def self.message

    @@message
  end
end

