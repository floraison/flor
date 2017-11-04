
class Flor::Pro::ToArray < Flor::Procedure
  #
  # Turns an argument into an array.
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
  # ## see also
  #
  # to-object

  name 'to-array'

  def pre_execute

    unatt_unkeyed_children
  end

  def receive

    determine_fcid_and_ncid

    if ! from_att? && (r = payload['ret'])
      @node['result'] = Flor.to_coll(r)
    end

    if last?
      ret = @node['result']
      fail ArgumentError.new("No argument given") unless ret
      payload['ret'] = ret
    end

    super
  end
end

