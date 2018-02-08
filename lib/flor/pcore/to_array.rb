
class Flor::Pro::ToArray < Flor::Procedure
  #
  # "to-array", turns an argument into an array, "to-object" turns it into
  # an object.
  #
  # ```
  # to-array [ 0 1 2 ]
  #   # --> [ 0 1 2 ]  # (left intact)
  #
  # to-array 123
  #   # --> [ 123 ]
  #
  # to-array { a: 'A', b: 'B' }
  #   # --> [ [ 'a', 'A' ], [ 'b', 'B' ] ]
  # ```
  #
  # and
  #
  # ```
  # to-object [ 'a' 'A' 'b' 'B' 'c' 'C' ]
  #   # --> { 'a': 'A', b: 'B', c: 'C' }
  # ```

  names %w[ to-array to-object ]

  def pre_execute

    @node['ret'] = receive_payload_ret

    unatt_unkeyed_children
  end

  def receive_last

    wrap_reply('ret' => (heap == 'to-object') ? to_object : to_array)
  end

  protected

  def to_array

    Flor.to_coll(@node['ret'])
  end

  def to_object

    r = @node['ret']

    fail Flor::FlorError.new('to-object wants an array (or an object)', self) \
      unless r.is_a?(Array) || r.is_a?(Hash)

    fail Flor::FlorError.new('to-object expects array with even length', self) \
      if r.is_a?(Array) && r.length.odd?

    r = r.each_slice(2).to_a if r.find { |e| ! e.is_a?(Array) }

    Hash[r]
  end
end

