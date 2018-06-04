
# india.rb

class IndiaTasker

  def initialize(ganger, conf, _)

    @ganger = ganger
    @conf = conf
  end

  def task(message)

    (message['payload']['tasked'] ||= []) << Flor.dup(message)

    @ganger.return(message)
  end
end

