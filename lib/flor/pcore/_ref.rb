
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
      elsif pa.size == 2 && pa[1] == 'ret' && field?(pa)
        parent ?
          parent_node_procedure.node_payload_ret :
          node_payload_ret
      else
        lookup_value(pa)
      end

    super
  end

  protected

  def field?(path)

    (s = path[0]) && s.is_a?(String) && s.match(/\Af(ld|ield)?\z/)
  end

  def lookup_value(path)

    super(path)

  rescue KeyError => ke

    return nil if field?(ke.work_path)
    return nil if child_id == 1 && (n = parent_node) && n['heat0'] == '_head'
    return nil if ke.miss[1].any? && ke.miss[4].empty?

    raise
  end
end

