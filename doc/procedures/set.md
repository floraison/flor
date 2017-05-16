
# set, setr

sets a field or a variable.

```
sequence
  set f.a 1        # sets the value `1` in the field 'a'
  set a false      # sets the `false` in the variable 'a'
  set v.b [ 1 2 ]  # sets `[ 1, 2 ]` in the variable 'b'
  set v.c.0 -1     # sets `-1` in first slot of the array in var 'c'
```

When set has a single child, it uses as value to copy the content of
payload.ret.

```
sequence
  "hello world"
  set a
#
# is equivalent to
#
sequence
  set a "hello world"
```

## splat

```
sequence
  set a b___ c
    [ 0 1 2 3 ]
      # ==> a: 0, b: [ 1, 2 ], c: 3
  set d e__2 f
    [ 4 5 6 7 8 ]
      # ==> d: 4, e: [ 5, 6 ], f: 7
  set __2 g h
    [ 9 10 11 12 13 ]
      # ==> g: 11, h: 12
      # `__` is not prefixed by a var name, so it justs discard
      # what it captures
  set i j___
    [ 14 15 16 17 18 19 ]
      # ==> i: 14, j: (15..19).to_a
  set "k__$(c)" l
    [ 20 21 22 23 24 ]
      # ==> k: [ 20, 21, 22 ], l: 23
```

## "setr"

"set", before terminating its execution carefully resets the payload.ret
value to what it was right before it started executing.
"setr" is a version of "set" that doesn't care and leave payload.ret to
value set by its last child (usually the value set).

```
  sequence
    123         # payload.ret is set to `123`
    set a 456   # var 'a' is set to 456, payload.ret is reset to `123`
    setr b 789  # var 'b' is set to `789`, payload.ret as well
```


* [source](https://github.com/floraison/flor/tree/master/lib/flor/pcore/set.rb)
* [set spec](https://github.com/floraison/flor/tree/master/spec/pcore/set_spec.rb)

