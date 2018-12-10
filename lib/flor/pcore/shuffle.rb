
class Flor::Pro::Shuffle < Flor::Procedure
  #
  # Returns a shuffled version of an array.
  #
  # ## shuffle
  #
  # ```
  # shuffle [ 0 1 2 3 4 ]
  #   # might set [ 3 2 0 1 4 ] in f.ret
  # shuffle [ 0 1 2 3 4 ] 2
  #   # might set [ 4 2 ] in f.ret
  # shuffle [ 0 1 2 3 4 ] count: 2
  #   # might set [ 4 2 ] in f.ret
  #
  # [ 0 1 2 3 4 ]
  # shuffle _
  #   # might set [ 4 0 2 1 3 ] in f.ret
  # ```
  #
  # ## sample
  #
  # When given a count integer, "sample" behaves exactly like "shuffle".
  # When not given a count, it returns a single, random, element of the given
  # array.
  #
  # ```
  # sample [ 'a' 'b' 'c' ]
  #   # might set 'b' in f.ret
  #
  # [ 'a' 'b' 'c' ]
  # sample _
  #   # might set 'b' in f.ret
  #
  # sample [ 'a' 'b' 'c' ] 2
  #   # might set [ 'c', 'b' ] in f.ret
  # ```
  #
  # ## see also
  #
  # Slice, index, and length

  names %w[ shuffle sample ]

  def pre_execute

    unatt_unkeyed_children

    @node['atts'] = []
    @node['rets'] = []
  end

  def receive_last

    arr =
      (@node['rets'] + [ node_payload_ret ])
        .find { |r| r.is_a?(Array) }

    fail Flor::FlorError.new("no array to #{heap}") unless arr

    cnt =
      att('count', nil) ||
      @node['rets'].find { |r| r.is_a?(Integer) }

    ret = arr.sample(cnt || arr.size)
    ret = ret.first if cnt == nil && heap == 'sample'

    wrap('ret' => ret)
  end
end

