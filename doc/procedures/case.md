
# case

The classical case form.

Takes a 'key' and then look at arrays until it finds one that contains
the key. When found, it executes the child immediately following the
winning array.

```
case level
  [ 0 1 2 ]; 'low'
  [ 3 4 5 ]; 'medium'
  else; 'high'
```
which is a ";"ed version of
```
case level
  [ 0 1 2 ]
  'low'
  [ 3 4 5 ]
  'medium'
  else
  'high'
```

Non-array values are OK:
```
case level
  0; 'zero'
  1; 'one'
  else; 'dunno'
```

## else

As seen in the example above, an "else" in lieu of an array acts as
a catchall and the child immediately following it is executed.

If there is no else and no matching array, the case terminates and
doesn't set the field "ret".

### v.matched and $(matched)

When it successfully matches, the matched value (the argument of the
"case") is placed in the local (local to the then or else branch)
variables under 'matched'.

```
case 6
  5; 'five'
  [ 1, 6 ]; v.matched
  else; 'zilch'
# returns, well, 6...
```

```
case 6
  5; 'five'
  [ 1, 6 ]; "matched! >$(matched)<"
  else; 'zilch'
# returns "matched! >6<"
```

## regular expressions

It's OK to match with regular expressions:
```
case 'ovomolzin'
  /a+/; 'ahahah'
  [ /u+/, /o+/ ]; 'ohohoh'   # <--- matches here
  else; 'else'
```

### v.match and $(match)

When matching with a regular expression, the local variable 'matched' is
set, as seen above, but also 'match':

```
case 'ovomolzin'
  /a+/; 'ahahah'
  [ /u+/, /^ovo(.+)$/ ]; "matched:$(match.1)"
  else; 'else'
# yields "matched:molzin"
```

### defaulting to f.ret

When nothing is explicitly provided for consideration by "case", the
incoming `f.ret` is used.

```
2
case
  [ 0 1 2 ]; 'low'
  6; 'high'
  else; 'over'
# yields 'low'
```

### incoming f.ret is preserved

"case" makes sure `f.ret` gets to its upon-entering-"case" value
when considered inside:

```
 7
 case (+ 3 4)
   5; 'cinq'
   [ f.ret ]; 'sept'
   6; 'six'
   else; 'whatever...'

 # yields 'sept'
```

```
"six"
case 6
  5; 'cinq'
  7; 'sept'
  6; "six $( f.ret | upcase _ )"
  else; 'je ne sais pas'

# yields "six SIX"
```

## see also

[Match](match.md), [cond](cond.md), [if](if.md).


* [source](https://github.com/floraison/flor/tree/master/lib/flor/pcore/case.rb)
* [case spec](https://github.com/floraison/flor/tree/master/spec/pcore/case_spec.rb)

