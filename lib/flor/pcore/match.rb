
class Flor::Pro::Match < Flor::Pro::Case
  #
  # "match" can be thought of as a "destructuring [case](case.md)".
  #
  # "match", like "case", matches its first argument or the incoming `f.ret`.
  #
  # It can do what "case" can do:
  # ```
  # match v0
  #   0; 'zero'
  #   1; 'one'
  #   else; v0
  # ```
  # (Please note that "case" accepts arrays of possible values, while "match"
  # does not, it reads arrays on the left side as patterns (see destructuring
  # arrays below))
  #
  # But it can also destructure arrays:
  # ```
  # # the classical FizzBuzz
  # match [ (% i 3) (% i 5) ]
  #   [ 0 0 ]; 'FizzBuzz'
  #   [ 0 _ ]; 'Fizz'
  #   [ _ 0 ]; 'Buzz'
  #   else; i
  # ```
  # and objects:
  # ```
  # match
  #  { type: 'car', brand: b, model: m }; "a $(b) model $(m)"
  #  { type: 'train', destination: d }; "a train heading for $(d)"
  #  else; "an unidentified mobile object"
  # ```
  #
  # Note the general left-side; right-side structure. There is a pattern on
  # the left-side as a condition and a consequent on the right-side. Variables
  # may be bound in the left-side and accessed in the right-side consequent.
  # In the above example, the "brand" is bound under the variable `b` and
  # thus accessed in the consequent (which just builds a string that will
  # be the return value of the whole "match").
  #
  # Note that this "left-side / right-side" distinction is arbitrary. The
  # code above may be written equivalently as
  # ```
  # match
  #  { type: 'car', brand: b, model: m }
  #  "a $(b) model $(m)"
  #  { type: 'train', destination: d }
  #  "a train heading for $(d)"
  #  else
  #  "an unidentified mobile object"
  # ```
  #
  # ## destructuring arrays
  # ```
  # match
  #   [ 1 _ ]; "an array with 2 elements, first one is 1"
  #   [ 1 _ 3 ]; "3 elts, starts with 1, ends with 3"
  #   [ 1 ___ 3 ]; "2 or more elts, starts with 1, ends with 3"
  #   [ a__2 __3 ]; "first 2 elts are $(a), in total 5 elts"
  # ```
  # Note the `_` that matches a single element, the `___` that matches
  # the "rest" but can be declined in `{binding-name}__{_|count}`, for
  # example, the `a__2` above means "take 2 elements and bind them under 'a'.
  #
  # ## destructuring objects
  # ### `only`
  # ### `quote: "keys"`
  # ### deep keys
  #
  # ## "or"
  # ## "or!"
  # ## "bind"
  # ## "guard"

  name 'match'

  def pre_execute

    unatt_unkeyed_children

    conditional = true
    @node['val'] = payload['ret'] if non_att_children.size.even?
    found_val = @node.has_key?('val')
    t = tree
    changed = false

    t[1].each_with_index do |ct, i|

      next if ct[0] == '_att'
      next(found_val = true) unless found_val
      next(conditional = true) unless conditional

      conditional = false
      t[1][i] = patternize(ct)
      changed = changed || t[1][i] != ct
    end

    @node['tree'] = t if changed
  end

  def execute_child(index=0, sub=nil, h=nil)

    t = tree[1][index]

    payload['_pat_val'] = @node['val'] \
      if t && t[0].match(/\A_pat_(arr|obj|or|guard)\z/)

    super
  end

  protected

  def patternize(t)

    return t unless t[1].is_a?(Array)

    bang = t[1]
      .index { |ct|
        ct[0] == '_att' &&
        ct[1].size == 1 &&
        ct[1][0][0, 2] == [ '!', [] ] }
    pat =
      case t[0]
      when '_arr', '_obj' then "_pat#{t[0]}"
      when 'or', 'guard' then "_pat_#{t[0]}"
      when 'bind' then '_pat_guard'
      when 'or!' then 'or'
      else nil
      end

    t[0] =
      if pat && bang
        t[1].delete_at(bang)
        t[0]
      elsif pat
        pat
      else
        t[0]
      end

    t[1].each_with_index { |ct, i| t[1][i] = patternize(t[1][i]) }

    t
  end

  def match?

    if b = payload.delete('_pat_binding')
      b
    else
      payload['ret'] == @node['val']
    end
  end

  def else?(ncid)

    t = tree[1][ncid]; return false unless t

    t[0, 2] == [ '_', [] ] ||
    t[0, 2] == [ 'else', [] ]
  end
end

