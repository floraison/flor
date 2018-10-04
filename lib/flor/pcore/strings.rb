
class Flor::Pro::Strings < Flor::Procedure
  #
  # "downcase", "upcase", "capitalize", etc.
  #
  # "downcase", "lowercase", "lowcase",
  # "upcase", "uppercase",
  # "capitalize",
  # "snakecase", "snake_case"
  #
  # ```
  # downcase 'HELLO'           # => 'hello'
  # 'HELLO'; downcase _        # => 'hello'
  # 'HELLO'; downcase 'WORLD'  # => 'world'
  # # ...
  # downcase 'WORLD'            # => 'world'
  # downcase 'WORLD' cap: true  # => 'World'
  # # ...
  # capitalize 'hello world'  # => 'Hello World'
  # ```
  #
  # The `cap:` attribute, when set to something trueish, will make sure the
  # resulting string(s) first char is capitalized. Not that "capitalize" itself
  # will capitalize all the words (unlike Ruby's `String#capitalize`).
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
    capitalize
    snakecase snake_case
    camelcase camelCase ]

  def pre_execute

    @node['ret'] = nil
    @node['atts'] = []

    unatt_unkeyed_children
  end

  def receive_payload_ret; payload['ret']; end # don't duplicate the ret

  def receive_last

    met =
      case h0 = @node['heat0']
      when 'downcase', 'lowercase', 'lowcase' then :downcase
      when 'upcase', 'uppercase' then :upcase
      when 'capitalize' then :capitalize
      when 'snakecase', 'snake_case' then :snakecase
      when 'camelcase', 'camelCase' then :camelcase
      else fail NotImplementedError.new("#{h0.inspect} not implemented")
      end
    ret =
      process(
        met,
        @node['ret'] || node_payload_ret,
        att('cap', 'capitalize'))

    wrap('ret' => ret)
  end

  protected

  def process(met, o, cap)

    r =
      case o
      when String then StringWrapper.new(o).send(met)
      when Array then o.collect { |e| process(met, e, cap) }
      when Hash then o.inject({}) { |h, (k, v)| h[k] = process(met, v, cap); h }
      else o
      end

    cap ?
      r.capitalize :
      r
  end

  class StringWrapper
    extend ::Forwardable

    def_delegators :@s, :downcase, :upcase

    def initialize(s); @s = s; end

    def camelcase

      @s
        .gsub(/_(.)/) { |_| $1.upcase }
    end

    def capitalize

      @s
        .gsub(/\b[a-z]/) { |c| c.upcase }
    end

    def snakecase

      @s
        .gsub(/([a-z])([A-Z])/) { |_| $1 + '_' + $2.downcase }
        .gsub(/([A-Z])/) { |c| c.downcase }
    end
  end
end

