
# break, continue

Breaks or continues a "while", "until", "loop" or a "cursor".

```
until false
  # do something
  continue _ if f.x == 0
  break _ if f.x == 1
  # do something more
```

## ref:

Break and continue may be used from outside a loop, thanks to the
`ref:` attribute:

```
set l []
concurrence
  cursor tag: 'x0'
    push l 0
    stall _
  sequence
    push l 1
    break ref: 'x0'

# where l ends up containing [ 1, 0 ]
```

## "aliasing"

A continue or a break may be "aliased", in other words stored in a
local variable for reference in a sub-loop.

```
cursor
  set outer-continue continue
  push f.l "$(nid)"
  cursor
    push f.l "$(nid)"
    outer-continue _ if "$(nid)" == '0_2_1_0_0'

# where l yields [ '0_1_1', '0_2_0_1', '0_1_1-1', '0_2_0_1-1' ]
```

## see also

[While](until.md), [until](until.md), [loop](loop.md) and [cursor](cursor.md).


* [source](https://github.com/floraison/flor/tree/master/lib/flor/pcore/break.rb)
* [break spec](https://github.com/floraison/flor/tree/master/spec/pcore/break_spec.rb)

