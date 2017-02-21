
class PutsTasker < Flor::BasicTasker

  def task

    if attd['all'] == true
      pp @message
    else
      puts attl[1..-1]
    end

    reply
  end
end

