
class Flor::Pro::Ref < Flor::Procedure

  names %w[ _ref _rep ]

  def pre_execute

    @node['rets'] = []
  end

  def receive_last

    rs = @node['rets']

    payload['ret'] =
      if tree[0] == '_rep'
        rs
      elsif rs.size == 2 && rs[1] == 'ret' && rs[0].match(/\Af(ld|ield)?\z/)
        node_payload_ret
      else
        lookup_value(rs)
      end

    super
  end
end

