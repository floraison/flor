# frozen_string_literal: true

class Flor::Pro::Reverse < Flor::Procedure
  #
  # Reverses an array or a string.
  #
  # ```
  # reverse [ 0, 2, 4 ]
  #   # --> sets f.ret to [ 4, 2, 0 ]
  # reverse "melimelo"
  #   # --> sets f.ret to "olemilem"
  # ```
  #
  # Reverses f.ret if there are no arguments
  # ```
  # [ 5, 6, 4 ]   # sets f.ret to [ 5, 6, 4 ]
  # reverse _     # sets f.ret to [ 4, 6, 5 ]
  # ```
  #
  # Will fail if it finds nothing reversible.
  #
  # # see also
  #
  # shuffle, sort, and sort_by

  name 'reverse'

  def pre_execute

    @node['ret'] = receive_payload_ret

    unatt_unkeyed_children
  end

  def receive_payload_ret

    r = payload['ret']
    r.respond_to?(:reverse) ? r.reverse : false
  end

  def receive_last

    r =
      @node['ret'] ||
      fail(
        Flor::FlorError.new('found no argument that could be reversed', self))

    wrap_reply('ret' => r)
  end
end

