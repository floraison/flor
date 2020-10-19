# frozen_string_literal: true

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
  # ```
  # [ 1 2 3 ]
  # + _ # ==> 6
  #
  # [ 2 3 4 ]
  # * _ # ==> 24
  # ```
  #
  # ```
  # + "hell" "o"
  # "hel" + "lo"
  #   # both yield "hello"
  # ```

  names %w[ + - * / % ]

  DEFAULTS = { :+ => 0, :* => 1, :- => 0, :/ => 1 }

  def pre_execute

    @node['rets'] = []
    @node['atts'] = []

    unatt_unkeyed_children
  end

  def receive_last

    sign = tree.first.to_sym

    rets = @node['rets']
    rets << node_payload_ret \
      if rets.empty? && node_payload_ret.is_a?(Array)
    rets = rets[0] \
      if rets.size == 1 && rets[0].is_a?(Array)

    fail Flor::FlorError.new('modulo % requires at least 2 arguments', self) \
      if sign == :% && rets.size < 2

    if j = att('join')
      max = rets.size - 1
      rets = rets.each_with_index.inject([]) { |a, (e, i)|
        a << e
        a << j if i < max
        a }
      rets[0] = stringify(rets[0]) \
        if rets.any? && j.is_a?(String)
    end

    ret =
      if rets.compact.empty?
        DEFAULTS[sign]
      elsif sign == :+
        rets.reduce { |r, e|
          r + (r.is_a?(String) ? stringify(e) : e) }
      else
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

  protected

  def stringify(o)

    # TODO use djan instead of #to_s?
    # TODO use JSON instead of #to_s or djan?

    o.to_s
  end
end

