
# common attributes

Attributes shared by all the procedures.

## vars:

Vanilla procedures don't have variables set at their level. The `vars` attribute sets a vanilla hash in the targetted procedure.

## vars: hash

Passing a hash (dictionary) of variables sets those variables at the local level for the node and its sub-nodes. Once the flow leaves the node, the variables previous values (or non-values) get visible again.

```
sequence
  set a 0
  # a is set to 0, b is unknown

  sequence vars: { a: 1, b: 1 }
    # a is set to 1, b is set to 1
    set a 2
    # a is set to 2, b is set to 1

  # a is set to 0, b is unknown
```

## vars: array

Passing an array whitelists the variables visible to a node and its sub-nodes.

```
sequence vars: { a: 'A', b: 'B' }
  # a is set to 'A', b to 'B'
  sequence vars: [ 'a' ]
    # a is set to 'A', b is unknown
```

Regular expressions may be used within such an array:
```
sequence vars: { a_0: 'a', a_1: 'A', a_z: 'z', b_0: 'b' }
  # a_0, a_1, a_z and b_0 are set
  sequence vars: [ /^a_\d+/ ]
    # only a_0 and a_1 are visible
```

If the first element of the array is "-", "^" or "!", the array is a blacklist. The var names explicitely listed are bound to nil values (shadowing the value in the parent node).

An array beginning with a "+" is a whitelist.

Please note that the blacklist/whitelist mechanisms work by setting local variables that shadow upstream variables. Maybe "screening" is a better term than "listing".

## vars: '*' or 'copy'

TODO

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

## tag: / tags:

TODO

Read more on [tags](tags.md).

## on_cancel:

TODO

## on_error:

The rescue/catch mechanism in flor. Given a node sporting the `on_error:` attribute, whenever an error occurs at that node or a sub-node level, the subtree gets cancelled and then, the function pointed at by `on_error:` gets executed.

```
set f.l []
sequence on_error: (def msg, err \ push f.l err.msg)
  push f.l 0
  push f.l x
  push f.l 1
```
An execution of this flow ends up with the field l containing `[ 0, "don't know how to apply \"x\"" ]` and the error is silenced.

The on_error attribute has a procedure counterpart [on_error](procedures/on_error.md) and the procedure [on](procedures/on.md) may also be used with the `error` symbol to wrap a on-error block.

## timeout:

A timeout may be set on any node.

```
sequence timeout: 60 # seconds
  alice 'perform task a'
  bob 'perform task b'
sequence
  charly 'perform task c' timeout: '2d12h' # two days and twelve hours
  david 'perform task d'
```

Alice and Bob have 60 to peform their tasks (they're probably automated) while Charly has 2 days and 12 hours. David has no time constraint.

When a timeout triggers, the subtree rooted in the node with the timeout: attribute gets cancelled

See "on_timeout:" below for calling a function when the timeout cancel completes.

## on_timeout:

One can point the on_timeout: attribute to a function that will be executed when the node times out.

```
sequence timeout: '3d' on_timeout: (def msg \ alice 'decommission tasks a and b')
  alice 'perform task a'
  bob 'perform task b'
```

TODO continue me (on_timeout and timeout at higher/lower levels)

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

