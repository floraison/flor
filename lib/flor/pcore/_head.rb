
class Flor::Pro::Head < Flor::Procedure

  name '_head'

  def receive

    return execute_child(1) \
      if @message['point'] == 'execute'
        #
        # notice how it skips the first _sqs child

    h = [ tree[1][0][1], payload['ret'] ]
    h[1] = node_payload_ret if h[0].match(/\Af(ld|ield)?\.ret\z/)

    fail Flor::FlorError.new("don't know how to apply #{h[0].inspect}") \
      if h[1] == nil

    return execute_child(2, nil, '__head' => h) \
      if @message['from'].match(/_1\z/)

    super
  end
end

