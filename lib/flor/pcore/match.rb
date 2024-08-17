# frozen_string_literal: true

class Flor::Pro::Match < Flor::Pro::Case
  #
  # A kind of "destructuring [case](case.md)".
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
  #
  # As seen above, match with an object pattern lets one destructure and match.
  # ```
  # match
  #  { type: 'car', brand: b, model: m }; "a $(b) model $(m)"
  #  { type: 'train', destination: d }; "a train heading for $(d)"
  #  else; "an unidentified mobile object"
  # ```
  #
  # ### `only`
  #
  # By default, "match" only looks at the keys given by the pattern. If there
  # are entries under other keys in the value, it doesn't care, it matches.
  # With "only", it expects the value to have the same keys as the pattern.
  # ```
  # set o { 'type': 'car', 'brand': 'simca' }
  # set msg0
  #   match o
  #    { type: 'car' }; "it's a car"       # <=== matches here
  #    else; "it's something else"
  # set msg1
  #   match o
  #    { type: 'car' } only; "it's a car"
  #    else; "it's something else"         # <=== matches here
  # ```
  #
  # ### `quote: "keys"`
  #
  # By default, the keys in the pattern are extrapolated.
  # ```
  # set a 'A'
  # set b 'B'
  # match
  #   { a: 1, b: 2 }; 'match'
  #   else; 'no-match'
  # ```
  # is thus equivalent to
  # ```
  # match
  #   { 'A': 1, 'B': 2 }; 'match'
  #   else; 'no-match'
  # ```
  #
  # One can make sure keys are not extrapolated by quoting them all or by
  # using the `quote: keys` attribute on the pattern:
  # ```
  # match
  #   { a: 1, b: 2 } quote: keys; 'match'
  #   else; 'no-match'
  # ```
  #
  # Probably, quoting manually makes the pattern easier to read than forcing
  # `quote: keys` on it.
  #
  # ### deep keys
  #
  # The object pattern is OK with "deep keys", keys pointing at subelements
  # in the object being matched.
  # ```
  # set o { player: { name: 'Eldred', 'number': 55 } }
  # # ...
  # match o
  #   { player.name: 'Eldred' }; 'USA'   # <=== will match here
  #   { player.name: 'Johnson' }; 'USA'
  #   else; 'Japan'
  # ```
  #
  # ## "or"
  #
  # ```
  # match
  #   { age: (99 or 100) }; 'match'
  #   else; 'no-match'
  # ```
  #
  # ## "or!"
  #
  # Using "or!" forces match not to transform "or" into "_pat_or". "or" thus
  # stays the boolean logic "or" and returns true or false (while the "or",
  # _pat_or above returns match/no-match in the "match" context).
  #
  # "or!" is best used in conjunction with "guard"
  # ```
  # match
  #   { age: (guard a (or! (a < 10) (a > 99))) }; "kid or centenary"
  #   else; "normal age"
  # ```
  #
  # ## "bind"
  #
  # "bind" binds explicitly a value and allows for a sub-pattern.
  # ```
  # match [ 1 4 ]
  #   [ 1 (bind y (or 2 3)) ]; "match y:$(y)"
  #   [ 1 (bind x (or 4 5)) ]; "match x:$(x)"
  #   else; 'no-match'
  # ```
  #
  # Behind the scenes, "bind" is an alias for "guard".
  #
  # ## "guard"
  #
  # "guard", like "bind" and "or" is used inside of array or object patterns
  # to run a condition on some element or entry.
  # ```
  # set title
  #   match
  #     { age: (guard a (> 35)), function: f }; "senior $(f)"
  #     { sex: 'female' }; 'ms'
  #     else; 'mr'
  # ```
  #
  # "guard" takes at least a name argument, then optional pattern or
  # conditional arguments. The name is bound and available in the pattern /
  # conditional arguments.
  # ```
  # (guard {name})
  # (guard {name} {pattern|conditional}*)
  # ```
  #
  # ## see also
  #
  # Case, if, cond.

  name 'match'

  def pre_execute

    unatt_unkeyed_children

    conditional = true
    @node['val'] = payload['ret'] if non_att_count.even?
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
      if t && t[0].match(/\A_pat_(arr|obj|or|guard|regex)\z/)

    super
  end

  protected

  def patternize(t)

    return [ '_pat_regex', *t[1..-1] ] if t[0] == '_rxs'

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

