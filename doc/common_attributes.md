
# common attributes

Attributes shared by all the procedures.

# vars:

Vanilla procedures don't have variables set at their level. The `vars` attribute sets a vanilla hash in the targetted procedure.

## vars: hash

```
sequence
  set a: 0
  # a is set to 1, b is unknown

  sequence vars: { a: 1, b: 1 }
    # a is set to 1, b is set to 1
    set a: 2
    # a is set to 2, b is set to 1

  # a is set to 1, b is unknown
```

## vars: array

TODO

## vars: '*' or 'copy'

```
sequence vars: { a: 'A', b: 'B' }
  sequence vars: '*'
    # copies locally all the known vars at that point
```

# ret:

Sets the `payload: { ret: val }` (the return value).

It may be used to funny effects:
```
sequence
  1
  # f.ret is set to 1
  2 ret: 3
  # f.ret is set to 3
```

# flank:

Explicitely flags a procedure as "flanking".

In this sample, the `a; b` sequence happens in parallel to the `c; d` parent sequence. As soon as `d` replies to its parent sequence, the flanking child will get cancelled.

```
sequence
  sequence flank
    a
    b
  c
  d
```

