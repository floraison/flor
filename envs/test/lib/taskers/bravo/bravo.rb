
# alpha.rb

class BravoTasker

  def initialize(tasker, conf)

    @tasker = tasker
    @conf = conf
  end

  def task(message)

    # do nothing at all
  end

  def cancel(message)

    message['payload']['ret'] = 'bravo cancelled'

    @tasker.return(message)
  end
end

