
# hole.rb

class HoleTasker

  def initialize(ganger, conf)

    @ganger = ganger
  end

  def task(message)

    @@message = Flor.dup(message)
    # do nothing
  end

  def cancel(message)

    (message['payload'] ||= {})['holed'] = @@message
    @@message = nil

    @ganger.return(message)
  end

  def self.message

    @@message
  end
end

