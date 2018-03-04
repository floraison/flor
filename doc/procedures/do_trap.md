
# do-trap

A version of trap that accepts a block instead of a function.

do-trap accepts the same attributes as [trap][trap.md] does.

```
sequence
  do-trap 'terminated'
    trace "terminated(f:$(msg.from))"
  trace "here($(nid))"
```
which traces to:
```
here(0_1_0_0)
terminated(f:0)
```

## see also

[Trap](trap.md), [on](on.md), [signal](signal.md).


* [source](https://github.com/floraison/flor/tree/master/lib/flor/punit/do_trap.rb)

