
class FailfoxTwoTasker < Flor::BasicTasker

  def task

    fail 'hard!'

    reply

  rescue => err

    reply_with_error(err)
  end
end

