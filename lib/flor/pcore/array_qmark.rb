
class Flor::Pro::ArrayQmark < Flor::Procedure

  names %w[
    array? object? boolean? number? string? null?
    list? dict? hash? nil?
    false? true?
    pair? float? ]

  def pre_execute

    @node['ret'] = receive_payload_ret

    unatt_unkeyed_children
  end

  def receive_last

    t = Flor.type(@node['ret'])

    r =
      case h0 = @node['heat0']

      when 'array?', 'list?' then t == :array
      when 'object?', 'hash?' 'dict?' then t == :object
      when 'boolean?' then t == :boolean
      when 'number?' then t == :number
      when 'string?' then t == :string
      when 'null?', 'nil?' then t == :null

      when 'false?' then @node['ret'] == false
      when 'true?' then @node['ret'] == true

      when 'pair?' then t == :array && @node['ret'].length == 2
      when 'float?' then t == :number && @node['ret'].to_s.index('.') != nil

      else fail(Flor::FlorError.new("#{h0.inspect} not yet implemented", self))
      end

    wrap_reply('ret' => r)
  end

  def receive_payload_ret; payload['ret']; end # don't duplicate the ret
end

