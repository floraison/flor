
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
  # Will fail if it finds nothing reversable.

  name 'reverse'

  def pre_execute

    unatt_unkeyed_children
  end

  def receive

    determine_fcid_and_ncid

    if ! from_att? && ((r = payload['ret']).respond_to?(:reverse))
      @node['result'] = r.reverse
    end

    if last_receive?
      payload['ret'] =
        @node['result'] ||
        fail(
          Flor::FlorError.new('Found no argument that could be reversed', self))
    end

    super
  end
end

