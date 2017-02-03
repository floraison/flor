
# emil.rb

class EmilTasker

  def initialize(tasker, conf, message)

    @tasker = tasker
    @conf = conf
    @message = message
  end

  def task

    @message['payload']['emil'] = 'was here'

    @tasker.reply(@message)
  end
end

