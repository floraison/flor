
class Flor::Pro::Merge < Flor::Procedure
  #
  # Merges objects or arrays.
  #
  # With objects:
  # ```
  # merge {}           # => {}
  # merge { a: 0 }     # => { 'a' => 0 }
  # {}; merge _        # => {}
  # { a: 0 }; merge _  # => { 'a' => 0 }
  #
  # merge { a: 0 b: 1 } { b: 'B' c: 'C' }
  #  # => { 'a' => 0, 'b' => 'B', 'c' => 'C' }
  # merge { b: 'B' c: 'C' } { a: 0 b: 1 }
  #  # => { 'a' => 0, 'b' => 1, 'c' => 'C' },
  # ```
  #
  # With arrays:
  # ```
  # merge [ 0 1 2 3 ] [ 'a' 'b' 'c' ]
  #   # => [ 'a', 'b', 'c', 3 ],
  #
  # merge []            # => []
  # merge [ 0 1 2 ]     # => [ 0, 1, 2 ]
  # []; merge _         # => []
  # [ 0 1 2 ]; merge _  # => [ 0, 1, 2 ]
  # ```
  #
  # It determines if it has to deal with arrays or objects by looking at its
  # first argument (not the incoming ret).
  #
  # It fails if the arguments are not all objects or not all arrays.
  #
  # If the attribute `lax:` (or `loose:`) is set to `true`, it doesn't care
  # about non matching arguments and merges anyway:
  # ```
  # merge { a: 0 } { b: 1 } 'nada' { c: 2 } lax: true
  #   # => { 'a' => 0, 'b' => 1, 'c' => 2 }
  # merge { a: 0 } { b: 1 } { c: 2 }
  #   # => { 'a' => 0, 'b' => 1, 'c' => 2 }
  # merge { a: 0 } { b: 1 } 'nada' { c: 2 } tags: 'xxx' loose: true
  #   # => { 'a' => 0, 'b' => 1, 'c' => 2 }
  # ```
  #
  # `strict: false` is OK as well:
  # ```
  # merge { a: 0 } { b: 1 } 'nada' { c: 2 } strict: false
  #   # => { 'a' => 0, 'b' => 1, 'c' => 2 }
  # ```
  #
  #
  # ## see also
  #
  # reverse, length, keys

  name 'merge'

  def pre_execute

    @node['atts'] = []
    @node['rets'] = []

    unatt_unkeyed_children
  end

  def receive_last

    rets =
      ([ node_payload_ret ] + @node['rets'])
        .select { |e| e.is_a?(Array) || e.is_a?(Hash) }

    fail Flor::FlorError.new('found no array or object to merge', self) \
      if rets.empty?

    kla = rets[0].is_a?(Array) ? Array : Hash
    kln = Flor.type(rets[0])

    unless att('lax', 'loose') == true || att('strict') == false
      if (orets = @node['rets'].reject { |e| e.is_a?(kla) }).any?
        fail Flor::FlorError.new(
          "found a non-#{kln} item (#{Flor.type(orets[0])} item)", self)
      end
    end

    r = send(
      kla == Array ? :merge_arrays : :merge_objects,
      rets.select { |e| e.is_a?(kla) })

    wrap('ret' => r)
  end

  protected

  def merge_arrays(rets)

    rets
      .inject([]) { |r, a| a.each_with_index { |e, i| r[i] = e }; r }
  end

  def merge_objects(rets)

    rets
      .inject({}) { |r, h| r.merge(h) }
  end
end

