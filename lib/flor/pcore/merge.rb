
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
  #
  # ## see also
  #
  # reverse, length, keys

  name 'merge'

  def pre_execute

    @node['rets'] = []
  end

  def receive_last

    c0 = rets.find { |e| e.is_a?(Array) || e.is_a?(Hash) }

    fail Flor::FlorError.new('found no array or object to merge', self) \
      unless c0

    wrap('ret' => c0.is_a?(Array) ? merge_arrays : merge_objects)
  end

  protected

  def rets

    @rets ||= [ node_payload_ret ] + @node['rets']
  end

  def merge_arrays

    rets
      .select { |e| e.is_a?(Array) }
      .inject([]) { |r, a| a.each_with_index { |e, i| r[i] = e }; r }
  end

  def merge_objects

    rets
      .select { |e| e.is_a?(Hash) }
      .inject({}) { |r, h| r.merge(h) }
  end
end

