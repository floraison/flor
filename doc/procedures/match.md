
# match

"match" can be thought of as a "destructuring [case](case.md)".

"match", like "case", matches its first argument or the incoming `f.ret`.

It can do what "case" can do:
```
match v0
  0; 'zero'
  1; 'one'
  else; v0
```
(Please note that "case" accepts arrays of possible values, while "match"
does not, it reads arrays on the left side as patterns (see destructuring
arrays below))

But it can also destructure arrays:
```
# the classical FizzBuzz
match [ (% i 3) (% i 5) ]
  [ 0 0 ]; 'FizzBuzz'
  [ 0 _ ]; 'Fizz'
  [ _ 0 ]; 'Buzz'
  else; i
```
and objects:
```
match
 { type: 'car', brand: b, model: m }; "a $(b) model $(m)"
 { type: 'train', destination: d }; "a train heading for $(d)"
 else; "an unidentified mobile object"
```

Note the general left-side; right-side structure. There is a pattern on
the left-side as a condition and a consequent on the right-side. Variables
may be bound in the left-side and accessed in the right-side consequent.
In the above example, the "brand" is bound under the variable `b` and
thus accessed in the consequent (which just builds a string that will
be the return value of the whole "match").

Note that this "left-side / right-side" distinction is arbitrary. The
code above may be written equivalently as
```
match
 { type: 'car', brand: b, model: m }
 "a $(b) model $(m)"
 { type: 'train', destination: d }
 "a train heading for $(d)"
 else
 "an unidentified mobile object"
```

## destructuring arrays
```
match
  [ 1 _ ]; "an array with 2 elements, first one is 1"
  [ 1 _ 3 ]; "3 elts, starts with 1, ends with 3"
  [ 1 ___ 3 ]; "2 or more elts, starts with 1, ends with 3"
  [ a__2 __3 ]; "first 2 elts are $(a), in total 5 elts"
```
Note the `_` that matches a single element, the `___` that matches
the "rest" but can be declined in `{binding-name}__{_|count}`, for
example, the `a__2` above means "take 2 elements and bind them under 'a'.

## destructuring objects
### `only`
### `quote: "keys"`
### deep keys

## "or"
## "or!"
## "bind"
## "guard"


* [source](https://github.com/floraison/flor/tree/master/lib/flor/pcore/match.rb)
* [match spec](https://github.com/floraison/flor/tree/master/spec/pcore/match_spec.rb)

