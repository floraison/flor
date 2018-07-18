
class Flor::Pro::Ref < Flor::Procedure

  names %w[ _ref _rep ]

  def pre_execute

    @node['rets'] = []
  end

  def receive_last

    rs = @node['rets']
    rs = rs[0] if rs.size == 1 && rs[0].match(/[.\[]/)
    pa = Dense::Path.make(rs).to_a

    payload['ret'] =
      if tree[0] == '_rep'
        pa
      elsif pa.size == 2 && pa[1] == 'ret' && pa[0].match(/\Af(ld|ield)?\z/)
        node_payload_ret
      else
        lookup_value(pa)
      end

    super
  end
end

