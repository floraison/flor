# frozen_string_literal: true

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
  # ### v.matched and $(matched)
  #
  # When it successfully matches, the matched value (the argument of the
  # "case") is placed in the local (local to the then or else branch)
  # variables under 'matched'.
  #
  # ```
  # case 6
  #   5; 'five'
  #   [ 1, 6 ]; v.matched
  #   else; 'zilch'
  # # returns, well, 6...
  # ```
  #
  # ```
  # case 6
  #   5; 'five'
  #   [ 1, 6 ]; "matched! >$(matched)<"
  #   else; 'zilch'
  # # returns "matched! >6<"
  # ```
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
  #
  # ### v.match and $(match)
  #
  # When matching with a regular expression, the local variable 'matched' is
  # set, as seen above, but also 'match':
  #
  # ```
  # case 'ovomolzin'
  #   /a+/; 'ahahah'
  #   [ /u+/, /^ovo(.+)$/ ]; "matched:$(match.1)"
  #   else; 'else'
  # # yields "matched:molzin"
  # ```
  #
  # ### defaulting to f.ret
  #
  # When nothing is explicitly provided for consideration by "case", the
  # incoming `f.ret` is used.
  #
  # ```
  # 2
  # case
  #   [ 0 1 2 ]; 'low'
  #   6; 'high'
  #   else; 'over'
  # # yields 'low'
  # ```
  #
  # ### incoming f.ret is preserved
  #
  # "case" makes sure `f.ret` gets to its upon-entering-"case" value
  # when considered inside:
  #
  # ```
  #  7
  #  case (+ 3 4)
  #    5; 'cinq'
  #    [ f.ret ]; 'sept'
  #    6; 'six'
  #    else; 'whatever...'
  #
  #  # yields 'sept'
  # ```
  #
  # ```
  # "six"
  # case 6
  #   5; 'cinq'
  #   7; 'sept'
  #   6; "six $( f.ret | upcase _ )"
  #   else; 'je ne sais pas'
  #
  # # yields "six SIX"
  # ```
  #
  # ## see also
  #
  # Match, cond, if.

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

    array.each do |e|
      m = do_match?(e, v)
      return m if m
    end

    nil
  end

  def do_match?(elt, val)

    return { 'matched' => elt } if elt == val

    m = val.is_a?(String) && elt.is_a?(Regexp) && elt.match(val)
    return { 'matched' => elt, 'match' => m.to_a } if m

    nil
  end

  def array

    a = payload['ret']
    a = [ a ] if Flor.is_regex_tree?(a) || ! a.is_a?(Array)
    a.collect { |e| Flor.is_regex_tree?(e) ? Flor.to_regex(e) : e }
  end
end

