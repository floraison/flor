
class Flor::Pro::Atom < Flor::Procedure

  names %w[ _num _boo _sqs _nul _func ]

  def execute

    payload['ret'] =
      case heap
      when '_nul' then nil
      when '_func' then tree
      else tree[1]
      end

    wrap_reply
  end
end

