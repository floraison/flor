
# alpha.rb

class AlphaTasker

  def initialize(tasker, conf)

    @tasker = tasker
    @conf = conf
  end

  def task(message)

    pl = message['payload'].select { |k, v| k != 'seen' }

    (message['payload']['seen'] ||= []) <<
      [ message['tasker'], self.class, Time.now, Flor.dup(pl) ]

    @tasker.reply(message)
  end
end

