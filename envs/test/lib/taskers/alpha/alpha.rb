
# alpha.rb

class AlphaTasker

  def initialize(tasker, conf)

    @tasker = tasker
    @conf = conf
  end

  def task(message)

    message['payload']['seen'] =
      [ message['tasker'], self.class, Time.now ]

    @tasker.reply(message)
  end
end

