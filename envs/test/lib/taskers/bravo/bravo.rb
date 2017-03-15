
# alpha.rb

class BravoTasker

  def initialize(ganger, conf)

    @ganger = ganger
  end

  def task(message)

    # do nothing at all
  end

  def cancel(message)

    message['payload']['ret'] = 'bravo cancelled'

    @ganger.return(message)
  end
end

