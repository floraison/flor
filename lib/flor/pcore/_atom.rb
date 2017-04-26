
class Flor::Pro::Atom < Flor::Procedure

  names %w[ _num _boo _sqs _dqs _rxs _nul _func ]

  def execute

    payload['ret'] =
      case @node['heat0']
        when '_nul' then nil
        when '_dqs' then expand(tree[1])
        when '_rxs' then [ tree[0], expand(tree[1]), *tree[2..-1] ]
        when '_func' then tree
        else tree[1]
      end

    wrap_reply
  end
end

