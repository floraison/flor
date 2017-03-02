
class Flor::Pro::Case < Flor::Procedure
  #
  # The classical case form.
  #
  # Takes a 'key' and then look at arrays until it finds one that contains
  # the key. When found, it executes the child immediately following the
  # winning array.
  #
  # ```
  # case level
  #   [ 0 1 2 ];; 'low'
  #   [ 3 4 5 ];; 'medium'
  #   else;; 'high'
  # ```
  # which is a ";;"ed version of
  # ```
  # case level
  #   [ 0 1 2 ]
  #   'low'
  #   [ 3 4 5 ]
  #   'medium'
  #   else
  #   'high'
  # ```
  #
  # ## else
  #
  # As seen in the example above, an "else" in lieu of an array acts as
  # a catchall and the child immediately following it is executed.
  #
  # If there is no else and no matching array, the case terminates and
  # doesn't set the field "ret".

  name 'case'

  def pre_execute

    unatt_unkeyed_children
  end

  def receive_non_att

    return reply if @node['found']

    return receive_array if @node.has_key?('key')

    @node['key'] = payload['ret']
    super
  end

  protected

  def receive_array

    a = payload['ret']
    a = a.nil? ? [ a ] : Array(a)

    payload['ret'] = node_payload_ret

    if a.include?(@node['key'])

      @node['found'] = true
      execute_child(@fcid + 1)

    else

      t = tree[1][@fcid + 2]

      if t && t[0, 2] == [ 'else', [] ]
        @node['found'] = true
        execute_child(@fcid + 3)
      else
        execute_child(@fcid + 2)
      end
    end
  end
end

