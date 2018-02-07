
class Flor::Pro::Keys < Flor::Procedure
  #
  # Returns the "keys" or the "values" of an object.
  #
  # ```
  # keys { a: 'A', b: 'B' }
  #   # f.ret --> [ 'a', 'b' ]
  # values { a: 'A', b: 'B' }
  #   # f.ret --> [ 'A', 'B' ]
  # ```
  #
  # When used against an array, the indexes will be the numerical indexes
  # 0 to array length - 1.
  #
  # ```
  # keys [ 1, 'to', true ]
  #   # f.ret -> [ 0, 1, 2 ]
  # values [ 1, 'to', true ]
  #   # f.ret -> [ 1, 'to', true ]
  # ```
  #
  # When used against something that is neither an object nor an array
  # it will fail.
  #
  # ## see also
  #
  # length

  names %w{ keys values }

  def pre_execute

    unatt_unkeyed_children
  end

  def receive

    determine_fcid_and_ncid

    if ! from_att? && ((r = payload['ret']).respond_to?(:length))

      @node['result'] =
        case r
        when Hash then heap == 'keys' ? r.keys : r.values
        when Array then heap == 'keys' ? (0..r.length - 1).to_a : r
        else r.class
        end
    end

    if last_receive?

      r = @node['result']

      fail Flor::FlorError.new(
        "No argument given", self
      ) if r.nil?
      fail Flor::FlorError.new(
        "Received argument of class #{r}, no #{heap}", self
      ) unless r.is_a?(Array)

      payload['ret'] = r
    end

    super
  end
end

