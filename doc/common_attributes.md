
# common attributes

Attributes shared by all the procedures.

## vars:

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

## ret:

Sets the `payload: { ret: val }` (the return value).

It may be used to funny effects:
```
sequence
  1
  # f.ret is set to 1
  2 ret: 3
  # f.ret is set to 3
```

## on_cancel:

TODO

## on_error:

The rescue/catch mechanism in flor. Given a node sporting the `on_error:` attribute, whenever an error occurs at that node or a sub-node level, the subtree gets cancelled and then, the function pointed at by `on_error:` gets executed.

```
set f.l []
sequence on_error: (def msg \ push f.l msg.error.msg)
  push f.l 0
  push f.l x
  push f.l 1
```
An execution of this flow ends up with the field l containing `[ 0, "don't know how to apply \"x\"" ]` and the error is silenced.

The on_error attribute has a procedure counterpart [on_error](procedures/on_error.md) and the procedure [on](procedures/on.md) may also be used with the `error` symbol to wrap a on-error block.

## timeout:

TODO

## on_timeout:

TODO

## flank:

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

