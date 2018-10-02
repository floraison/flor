
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

  names %w[ keys values ]

  def pre_execute

    @node['ret'] = receive_payload_ret

    unatt_unkeyed_children
  end

  def receive_last

    ret = @node['ret']

    fail Flor::FlorError.new(
      "no argument given", self
    ) if ret.nil?
    fail Flor::FlorError.new(
      "received argument of class #{ret.class}, no #{heap}", self
    ) unless Flor.is_collection?(ret)

    r =
      if ret.is_a?(Hash)
        heap == 'keys' ? ret.keys : ret.values
      else
        heap == 'keys' ? (0..ret.length - 1).to_a : ret
      end

    wrap_reply('ret' => r)
  end
end

