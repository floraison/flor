
# tasker.rb

class NetAcmeTasker

  def initialize(tasker, conf)

    @tasker = tasker
    @conf = conf
  end

  def task(message)

    [
      Flor.dup_and_merge(
        message,
        'tasker' => 'alpha', 'routed' => true)
    ]
  end
end

