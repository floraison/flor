
class Flor::Pro::Arith < Flor::Procedure

  names %w[ + - * / % ]

  DEFAULTS = { :+ => 0, :* => 1, :- => 0, :/ => 1 }

  def pre_execute

    @node['rets'] = []
  end

  def receive_last

    sign = tree.first.to_sym
    count = @node['rets'].size

    if sign == :% && count < 2
      fail ArgumentError.new(
        "modulo % requires at least 2 arguments (line #{tree[2]})")
    end

    payload['ret'] = @node['rets'].reduce(&sign) || DEFAULTS[sign]

    wrap_reply
  end
end

