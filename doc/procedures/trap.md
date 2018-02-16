
# trap

Watches the messages emitted in the execution and reacts when
a message matches certain criteria.

Once the trap is set (once the execution interprets its branch), it
will trigger for any matching message, unless the `count:` attribute
is set.

When the execution terminates, the trap is removed as well.

By default, the observation range is the execution, only messages
in the execution where the trap was set are considered.
The trap can be extended via the `range:` attribute.

"trap" triggers a function, while "on" triggers a block.

## the point: criterion

The simplest thing to trap is a 'point'. Here, the trap is set for
any message whose point is 'terminated':
```
sequence
  trap 'terminated'
    def msg \ trace "terminated(f:$(msg.from))"
  trace "here($(nid))"
    # OR
#sequence
#  trap 'terminated'
#    def msg \ trace "terminated(f:$(msg.from))"
#  trace "here($(nid))"
```

## the heap: criterion
## the heat: criterion

## the tag: criterion (and name:)

TODO

## the range: limit

TODO

## the count: limit

```
trap tag: 'x' count: 2
  # ...
```
will trigger when the execution enters the tag 'x', but will trigger only
twice.

## see also

[On](on.md) and [signal](signal.md).


* [source](https://github.com/floraison/flor/tree/master/lib/flor/punit/trap.rb)
* [trap spec](https://github.com/floraison/flor/tree/master/spec/punit/trap_spec.rb)

