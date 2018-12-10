
class Flor::Pro::ArrayQmark < Flor::Procedure
  #
  # Returns true if the argument or the incoming ret matches in type.
  #
  # ```
  # array? []        # => true,
  # []; array? _     # => true,
  # array? false     # => false,
  # false; array? _  # => false,
  #
  # object? {}     # => true,
  # object? false  # => false,
  #
  # number? 0       # => true,
  # number? 0.1     # => true,
  # number? "dang"  # => false,
  # number? []      # => false,
  #
  # string? "hello"  # => true,
  # string? []       # => false,
  #
  # true? true   # => true,
  # true? false  # => false,
  # true? 0      # => false,
  #
  # boolean? true   # => true,
  # boolean? false  # => true,
  # boolean? []     # => false,
  #
  # null? null  # => true,
  # null? 0     # => false,
  #
  # false? false    # => true,
  # false? true     # => false,
  # false? "false"  # => false,
  #
  # nil? null  # => true,
  # nil? 0     # => false,
  #
  # pair? [ 0 1 ]  # => true,
  # pair? []       # => false,
  # pair? 0        # => false,
  #
  # float? 1.0  # => true,
  # float? 1    # => false,
  # float? {}   # => false,
  #
  # boolean? true tag: "xxx"   # => true,
  # true; boolean? tag: "xxx"  # => true,
  # string? {} tag: "xxx"      # => false,
  # {}; string? tag: "xxx"     # => false,
  # ```
  #
  # ## see also
  #
  # type-of, type

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
      case h = heap

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

      else fail(Flor::FlorError.new("#{h.inspect} not yet implemented", self))
      end

    wrap_reply('ret' => r)
  end

  def receive_payload_ret; payload['ret']; end # don't duplicate the ret
end

