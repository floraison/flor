
class Flor::Pro::ArrayQmark < Flor::Procedure

  names %w[
    array? object? boolean? number? string? null?
    list? dict? hash? nil?
    false? true?
    pair? float? ]

  def pre_execute

    unatt_unkeyed_children
  end

  def receive_last

    ret =
      payload['ret']

    r =
      case h0 = @node['heat0']

      when 'array?', 'list?' then ret.is_a?(Array)
      when 'object?', 'hash?' 'dict?' then ret.is_a?(Hash)
      when 'boolean?' then ret == true || ret == false
      when 'number?' then ret.is_a?(Numeric)
      when 'string?' then ret.is_a?(String)
      when 'null?', 'nil?' then ret == nil

      when 'false?' then ret == false
      when 'true?' then ret == true

      when 'pair?' then ret.is_a?(Array) && ret.length == 2
      when 'float?' then ret.is_a?(Numeric) && ret.to_s.index('.') != nil

      else fail(Flor::FlorError.new("#{h0.inspect} not yet implemented", self))
      end

    wrap_reply('ret' => r)
  end
end

