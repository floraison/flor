
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

    ret =
      if @node['rets'].compact.empty?
        DEFAULTS[sign]
      elsif sign == :+
        @node['rets'].reduce { |r, e|
          # TODO use djan instead of #to_s?
          # TODO use JSON instead of #to_s or djan?
          r + (r.is_a?(String) ? e.to_s : e) }
      else
        rets = @node['rets']
        rets = rets.collect(&:to_f) \
          if sign == :/ || rets.find { |r| r.is_a?(Float) }
        rets.reduce(&sign)
      end

    unless ret.is_a?(String)
      round = ret.round
      ret = round if round.to_f.to_s == ret.to_f.to_s
    end
      # follow JSON somehow, in show "1.0" as "1"...

    wrap_reply('ret' => ret)
  end
end

