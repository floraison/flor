
# envs/test/lib/taskers/kilo/lib/kilo.rb

module Kilo

  def self.on_message(message)

    [ Flor.dup_and_merge(
        message,
        'tasker' => 'Kilo::KaramelTasker', 'routed' => true) ]
  end
end

class Kilo::KaramelTasker < Flor::BasicTasker

  def task

    (payload['seen'] ||= []) << 'karamel'

    reply
  end
end

class Kilo::KinkTasker < Flor::BasicTasker

  def task

    # simply receive
  end

  def detask

    (payload['cancelled'] ||= []) << 'kink'

    reply
  end
end

module Kilo::Gram; end

class Kilo::Gram::MofonTasker < Flor::BasicTasker

  def tasker_name

    'mofon'
  end

  def task

    (payload['seen'] ||= []) << tasker_name

    reply
  end
end

