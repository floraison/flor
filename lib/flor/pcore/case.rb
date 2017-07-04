
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
  # Non-array values are OK:
  # ```
  # case level
  #   0; 'zero'
  #   1; 'one'
  #   else; 'dunno'
  # ```
  #
  # ## else
  #
  # As seen in the example above, an "else" in lieu of an array acts as
  # a catchall and the child immediately following it is executed.
  #
  # If there is no else and no matching array, the case terminates and
  # doesn't set the field "ret".
  #
  # ## regular expressions
  #
  # It's OK to match with regular expressions:
  # ```
  # case 'ovomolzin'
  #   /a+/; 'ahahah'
  #   [ /u+/, /o+/ ]; 'ohohoh'   # <--- matches here
  #   else; 'else'
  # ```

  name 'case'

  def pre_execute

    unatt_unkeyed_children

    @node['val'] = payload['ret'] if non_att_count.even?
  end

  def receive

    return wrap_reply if @node['found']

    determine_fcid_and_ncid

    return execute_child(@ncid) if @fcid == nil

    has_no_val = ! @node.has_key?('val')

    if has_no_val && ! from_att?
      @node['val'] = payload['ret']
      execute_conditional
    elsif has_no_val
      execute_child(@ncid)
    elsif m = match?
      execute_then(@ncid, m)
    else
      execute_conditional(@ncid + 1)
    end
  end

  protected

  def execute_conditional(ncid=@ncid)

    if else?(ncid)
      execute_then(ncid + 1)
    else
      payload['ret'] = node_payload_ret
      execute_child(ncid)
    end
  end

  def execute_then(ncid, vars=nil)

    payload['ret'] = node_payload_ret
    @node['found'] = true

    h = vars.is_a?(Hash) ? { 'vars' => vars } : nil

    execute_child(ncid, nil, h)
  end

  def else?(ncid)

    (t = tree[1][ncid]) &&
    t[0, 2] == [ 'else', [] ]
  end

  def match?

    v = @node['val']
    array.find { |e| do_match?(e, v) }
  end

  def do_match?(elt, val)

    return true if elt == val
    return true if val.is_a?(String) && elt.is_a?(Regexp) && elt.match(val)
    false
  end

  def array

    a = payload['ret']
    a = [ a ] if Flor.is_regex_tree?(a) || ! a.is_a?(Array)
    a.collect { |e| Flor.is_regex_tree?(e) ? Flor.to_regex(e) : e }
  end
end

