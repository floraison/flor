
class Flor::Pro::Ref < Flor::Procedure

  names %w[ _ref _rep ]

  def pre_execute

    @node['rets'] = []
  end

  def receive_last

    payload['ret'] =
      if tree[0] == '_rep'
        @node['rets']
      else
        lookup_value(@node['rets'])
      end

    super
  end
end

