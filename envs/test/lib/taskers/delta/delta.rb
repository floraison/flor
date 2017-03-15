
# delta.rb

class DeltaTasker

  def initialize(ganger, conf)

    @ganger = ganger
    @conf = conf
  end

  def task(message)

    message['payload']['ret'] = 'dimitri'

    @ganger.return(message)
  end
end

