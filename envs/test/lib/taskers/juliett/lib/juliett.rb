
# envs/test/lib/taskers/juliett/
#   lib/juliett.rb

class AlfaTasker < Flor::BasicTasker

  def task

    (payload['seen'] ||= []) << 'alfa'

    reply
  end
end

class BrafoTasker < Flor::BasicTasker

  def task

    (payload['seen'] ||= []) << 'brafo'

    reply
  end
end

