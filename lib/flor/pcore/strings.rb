
class Flor::Pro::Strings < Flor::Procedure
  #
  # Functions that deal with strings
  #
  # "downcase", "lowercase", "lowcase",
  # "upcase", "uppercase",
  # "capitalize"
  #
  # ```
  # downcase 'HELLO'           # => 'hello'
  # 'HELLO'; downcase _        # => 'hello'
  # 'HELLO'; downcase 'WORLD'  # => 'world'
  # # ...
  # ```
  #
  # ## objects and arrays
  #
  # Please note:
  #
  # ```
  # [ "A" "BC" "D" ]; downcase _    # => [ 'a' 'bc' 'd' ]
  # { a: "A" b: "BC" }; downcase _  # => { a: 'a', b: 'bc' }
  # ```
  #
  # ## see also
  #
  # length, reverse

  names %w[
    downcase lowercase lowcase
    upcase uppercase
    capitalize ]

  # TODO snake_case, CamelCase, etc
  # TODO `capitalize "banana republic" all: true` => 'Banana Republic',

  def pre_execute

    @node['ret'] = nil

    unatt_unkeyed_children
  end

  def receive_payload_ret; payload['ret']; end # don't duplicate the ret

  def receive_last

    met =
      case h0 = @node['heat0']
      when 'downcase', 'lowercase', 'lowcase' then :downcase
      when 'upcase', 'uppercase' then :upcase
      when 'capitalize' then :capitalize
      #else :to_s
      else fail NotImplementedError.new("#{h0.inspect} not implemented")
      end
    ret =
      process(met, @node['ret'])

    wrap('ret' => ret)
  end

  protected

  def process(met, o)

    case o
    when String then o.send(met)
    when Array then o.collect { |e| process(met, e) }
    when Hash then o.inject({}) { |h, (k, v)| h[k] = process(met, v); h }
    else o
    end
  end
end

