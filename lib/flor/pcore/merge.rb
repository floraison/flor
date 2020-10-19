# frozen_string_literal: true

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
  # ## incoming ret
  #
  # "merge" only draws in the incoming ret if necessary. If there are
  # enough arguments to perform a merge, the incoming ret will not be taken
  # into account.
  # You can add the incoming to the merge simply with `f.ret`.
  #
  # ```
  # [ 0 1 2 ]; merge [ 0 1 'deux' 3 ]                    # => [ 0 1 'deux' 3 ]
  # [ 0 1 2 3 4 ]; merge [ 0 1 2 3 ] [ 0 'un' 2 ]        # => [ 0 'un' 2 3 ]
  # [ 0 1 2 3 4 ]; merge f.ret [ 0 1 2 3 ] [ 0 'un' 2 ]  # => [ 0 'un' 2 3 ]
  # [ 0 1 2 3 4 ]; merge [ 0 1 2 3 ] [ 0 'un' 2 ] f.ret  # => [ 0 1 2 3 4 ]
  # [ 0 ]; merge { a: 1 } { a: 'one' }                   # => { a: 'one' }
  # ```
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

    indexes = @node['rets']
      .each_with_index
      .inject({ array: [], object: [], other: [] }) { |is, (e, i)|
        case e
        when Array then is[:array]
        when Hash then is[:object]
        else is[:other]
        end << i
        is }

    a0 = indexes[:array].first || @node['rets'].length
    o0 = indexes[:object].first || @node['rets'].length

    kln = a0 < o0 ? :array : :object
    okln = kln == :array ? :object : :array

    cols = indexes[kln].collect { |i| @node['rets'][i] }

    cols.unshift(node_payload_ret) \
      if cols.length == 1 && Flor.type(node_payload_ret) == kln

    fail Flor::FlorError.new('found no array or object to merge', self) \
      if cols.empty?

    unless att('lax', 'loose') == true || att('strict') == false

      others = (indexes[:other] + indexes[okln]).sort

      fail Flor::FlorError.new(
        "found a non-#{kln} item (#{Flor.type(@node['rets'][others[0]])} item)",
        self
      ) if others.any?
    end

    wrap('ret' => send(kln == :array ? :merge_arrays : :merge_objects, cols))
  end

  protected

  def merge_arrays(as)

    as
      .inject([]) { |r, a| a.each_with_index { |e, i| r[i] = e }; r }
  end

  def merge_objects(os)

    os
      .inject({}) { |r, o| r.merge(o) }
  end
end

