
class Flor::Pro::Atom < Flor::Procedure

  names %w[ _num _boo _sqs _dqs _rxs _nul _func _lit ]

  def execute

    payload['ret'] =
      case @node['heat0']
      when '_nul' then nil
      when '_dqs' then expand(tree[1])
      when '_rxs' then [ tree[0], expand(tree[1]), *tree[2..-1] ]
      when '_func' then tree
      else
        if tree[1].is_a?(Array)
          if h = tree[1].find { |c| c.is_a?(Hash) }
            h
          else
            tree[1].reject { |ct| Flor.is_att_tree?(ct) }
          end
        else
          tree[1]
        end
      end

    wrap_reply
  end
end

