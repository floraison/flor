
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
  #   [ 0 1 2 ]; 'low'
  #   [ 3 4 5 ]; 'medium'
  #   else; 'high'
  # ```
  # which is a ";"ed version of
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

    @node['val'] = payload['ret'] if non_att_children.size.even?
  end

  def receive_last_att

    @last_att = true

    receive_non_att
  end

  def receive_non_att

    return wrap_reply if @node['found']

    if ! @last_att && ! @node.has_key?('val')
      @node['val'] = payload['ret']
    end

    return wrap_reply('ret' => node_payload_ret) unless tree[1][@ncid]

    return execute_child(@ncid) unless @node.has_key?('val')

    return match if @node['on']

    @node['on'] = true

    execute_next
  end

  protected

  def match

    if match?
      trigger
    else
      execute_next
    end
  end

  def execute_next

    if next_child_is_a_else?
      trigger(@ncid + 1)
    else
      payload['ret'] = node_payload_ret
      execute_child(@ncid)
    end
  end

  def trigger(ncid=@ncid)

    @node['found'] = true
    payload['ret'] = node_payload_ret

    execute_child(ncid)
  end

  def match?

    a = payload['ret']
    a = a.nil? ? [ a ] : Array(a)

    a.include?(@node['val'])
  end

  def next_child_is_a_else?

    tree[1][@ncid][0, 2] == [ 'else', [] ]
  end
end

