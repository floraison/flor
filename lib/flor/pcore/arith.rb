
class Flor::Pro::Arith < Flor::Procedure

  names %w[ + - * / ]

  DEFAULTS = { :+ => 0, :* => 1, :- => 0, :/ => 1 }

  def pre_execute

    @node['rets'] = []
  end

  def receive_last

    sign = tree.first.to_sym

    payload['ret'] = @node['rets'].reduce(&sign) || DEFAULTS[sign]

    wrap_reply
  end
end

