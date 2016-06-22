
# alpha.rb

class AlphaTasker

  def initialize(tasker, conf)

    @tasker = tasker
    @conf = conf
  end

  def task(tasker_name, fei, payload)

    payload['seen'] = [ tasker_name, self.class, Time.now ]

    @tasker.reply(tasker_name, fei, payload)
  end
end

