
class Flor::Pro::Length < Flor::Procedure
  #
  # Returns the length of its last collection argument or
  # the length of the incoming f.ret
  #
  # ```
  # length [ 0 1 2 3 ]
  #   # f.ret ==> 4
  #
  # { a: 'A', b: 'B', c: 'C' }
  # length _
  #   # f.ret ==> 3
  # ```
  #
  # It will fail unless "length" receives a (non-attribute) argument
  # that has a length.
  #
  # Has the "size" alias.

  names %w[ length size ]

  def pre_execute

    @node['ret'] = receive_payload_ret

    unatt_unkeyed_children
  end

  def receive_payload_ret

    r = payload['ret']
    r.respond_to?(:length) ? r.length : false
  end

  def receive_last

    r =
      @node['ret'] ||
      fail(Flor::FlorError.new('Found no argument that has a length', self))

    wrap_reply('ret' => r)
  end
end

