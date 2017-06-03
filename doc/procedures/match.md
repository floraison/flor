
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

But it can also destructure objects and arrays:
```
# the classical FizzBuzz
match [ (% i 3) (% i 5) ]
  [ 0 0 ]; 'FizzBuzz'
  [ 0 _ ]; 'Fizz'
  [ _ 0 ]; 'Buzz'
  else; i
```

```
match
 { type: 'car', brand: b, model: m }; "a $(b) model $(m)"
 { type: 'train', destination: d }; "a train heading for $(d)"
 else; "an unidentified mobile object"
```

## destructuring arrays
## destructuring objects
### deep keys

## "or"
## "or!"
## "bind"
## "guard"


* [source](https://github.com/floraison/flor/tree/master/lib/flor/pcore/match.rb)
* [match spec](https://github.com/floraison/flor/tree/master/spec/pcore/match_spec.rb)

