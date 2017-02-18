
# tasker.rb

class NetAcmeTasker

  def initialize(tasker, conf)

    @tasker = tasker
    @conf = conf
  end

  def task(message)

    return [
      Flor.dup_and_merge(message, 'routed' => false)
    ] if message['tasker'].match(/\Aunknown_/)

    [ Flor.dup_and_merge(message, 'tasker' => 'alpha', 'routed' => true) ]
  end
end

