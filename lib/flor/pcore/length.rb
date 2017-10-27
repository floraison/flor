
class Flor::Pro::Length < Flor::Procedure
  #
  # Returns the length of its last collection argument or
  # the length of the incoming f.ret
  #
  # ```
  #   length [ 0 1 2 3 ]
  #     # f.ret ==> 4
  #
  #   { a: 'A', b: 'B', c: 'C' }
  #   length _
  #     # f.ret ==> 3
  # ```
  #
  # It will fail unless "length" receives a (non-attribute) argument
  # that has a length.

  name 'length'

  def pre_execute

    unatt_unkeyed_children
  end

  def receive

    determine_fcid_and_ncid

    if ! from_att? && ((r = payload['ret']).respond_to?(:length))
      @node['result'] = r.length
    end

    if last?
      if result = @node['result']
        payload['ret'] = result
      else
        fail ArgumentError.new("Found no argument that has a length")
      end
    end

    super
  end
end

