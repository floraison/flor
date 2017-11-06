
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
  # to-object { 'a' 'A' 'b' 'B' 'c' 'C' }
  #   # --> { 'a': 'A', b: 'B', c: 'C' }
  # ```

  names %w[ to-array to-object ]

  def pre_execute

    unatt_unkeyed_children
  end

  def receive

    determine_fcid_and_ncid

    if ( ! from_att?) && (r = payload['ret'])
      @node['result'] = r
    end

    if last_receive?

      fail Flor::FlorError.new("#{tree[0]} needs an argument", self) \
        unless @node.has_key?('result')

      payload['ret'] =
        tree[0] == 'to-object' ? to_object : to_array
    end

    super
  end

  protected

  def to_array

    Flor.to_coll(@node['result'])
  end

  def to_object

    r = @node['result']

    fail Flor::FlorError.new('to-object wants an array (or an object)', self) \
      unless r.is_a?(Array) || r.is_a?(Hash)

    fail Flor::FlorError.new('to-object expects array with even length', self) \
      if r.is_a?(Array) && r.length.odd?

    r = r.each_slice(2).to_a if r.find { |e| ! e.is_a?(Array) }

    Hash[r]
  end
end

