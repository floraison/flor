
class Flor::Pro::Arith < Flor::Procedure
  #
  # The base implementation for + - + / %
  #
  # ```
  # (+ 1 2 3) # ==> 6
  #
  # +
  #   1
  #   2
  #   3 # ==> 6
  #
  # + \ 1; 2; 3 # ==> 6
  # ```
  #
  # ```
  # 1 - 2 - 3 # ==> -4
  #
  # -
  #   1
  #   2
  #   3 # ==> -4
  # ```
  #
  # ...

  names %w[ + - * / % ]

  DEFAULTS = { :+ => 0, :* => 1, :- => 0, :/ => 1 }

  def pre_execute

    @node['rets'] = []
  end

  def receive_last

    sign = tree.first.to_sym
    count = @node['rets'].size

    fail Flor::FlorError.new('modulo % requires at least 2 arguments', self) \
      if sign == :% && count < 2

    payload['ret'] =
      if @node['rets'].compact.empty?
        DEFAULTS[sign]
      elsif sign == :+
        @node['rets'].reduce { |r, e| r + (r.is_a?(String) ? e.to_s : e) }
      else
        @node['rets'].reduce(&sign)
      end

    wrap_reply
  end
end

