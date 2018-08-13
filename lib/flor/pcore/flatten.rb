
class Flor::Pro::Flatten < Flor::Procedure
  #
  # Flattens the given array
  #
  # ```
  # flatten [ 1, [ 2, [ 3 ], 4 ] ]     # ==> [ 1, 2, 3, 4 ]
  # flatten [ 1, [ 2, [ 3 ], 4 ] ], 1  # ==> [ 1, 2, [ 3 ], 4 ]
  #
  # [ 1, [ 2, [ 3 ], 4 ] ]
  # flatten 1  # ==> [ 1, 2, [ 3 ], 4 ]
  #
  # [ 1, [ 2, [ 3 ], 4 ] ]
  # flatten _  # ==> [ 1, 2, 3, 4 ]
  # ```

  name 'flatten'

  def pre_execute

    @node['rets'] = []

    unatt_unkeyed_children
  end

  def receive_last

    col = (@node['rets'] + [ node_payload_ret ])
      .find { |r| r.is_a?(Array) }

    lvl = @node['rets']
      .find { |r| r.is_a?(Integer) } || -1

    fail Flor::FlorError.new('missing collection', self) if col == nil

    wrap('ret' => col.flatten(lvl))
  end
end

