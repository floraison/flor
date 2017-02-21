
# alpha.rb

class AlphaTasker

  def initialize(tasker, conf)

    @tasker = tasker
    @conf = conf
  end

  def task(message)

    pl = message['payload'].select { |k, v| k != 'seen' }

    (message['payload']['seen'] ||= []) <<
      [
        message['tasker'],
        message['taskname'],
        self.class,
        Time.now,
        {
          'payload' => Flor.dup(pl),
          'attl' => message['attl'], 'attd' => message['attd']
        }
      ]

    @tasker.return(message)
  end
end

