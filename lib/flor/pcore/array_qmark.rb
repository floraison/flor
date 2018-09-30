
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

    ret = payload['ret']
    t = Flor.type(ret)

    r =
      case h0 = @node['heat0']

      when 'array?', 'list?' then t == :array
      when 'object?', 'hash?' 'dict?' then t == :object
      when 'boolean?' then t == :boolean
      when 'number?' then t == :number
      when 'string?' then t == :string
      when 'null?', 'nil?' then t == :null

      when 'false?' then ret == false
      when 'true?' then ret == true

      when 'pair?' then t == :array && ret.length == 2
      when 'float?' then t == :number && ret.to_s.index('.') != nil

      else fail(Flor::FlorError.new("#{h0.inspect} not yet implemented", self))
      end

    wrap_reply('ret' => r)
  end
end

