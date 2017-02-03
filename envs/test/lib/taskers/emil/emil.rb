
# emil.rb

class EmilTasker < Flor::BasicTasker

  def task

    message['payload']['emil'] = 'was here'

    reply
  end
end

