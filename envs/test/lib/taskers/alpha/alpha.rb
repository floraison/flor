
# alpha.rb

class AlphaTasker

  def initialize(tasker, conf)

    @tasker = tasker
    @conf = conf
  end

  def task(fei, payload)

    payload['seen'] = [ self.class, Time.now ]

    @tasker.reply(fei, payload)
  end
end

