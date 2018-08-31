
# tags

Tags are used to mark nodes in flows.

A node may be tagged with a single tag or multiple tags.
```
sequence tag: 'aa'
  sequence tag: 'bb', tag: 'cc'
    sequence tags: [ 'dd', 'ee' ]
      sequence tags: 'ff,gg'
        # ...
```


## 'entered' and 'left' messages

Upon entering a tag, an 'entered' message is emitted, while upon leaving a tag, a 'left' message is emitted.

Such message may be intercepted, by [hooks](hooks.md) or by [traps](traps.md).

```
sequence
  trace 'a'
  trap tag: 'x'
    def msg \ trace msg.point
  sequence tag: 'x'
    trace 'c'
```
results in a trace of `%w[ a c entered ]`. See [trap](procedures/trap.md).

TODO hook example


## tags and loops

A tag may also be used to flag a certain loop procedure ([loop](procedures/loop.md) or [until](procedures/until.md)):

```
set l []
concurrence
  until false tag: 'x0'
    push l 0
    stall _
  sequence
    push l 1
    break ref: 'x0'
```

[break and continue](procedures/break.md) may thus use a `ref:` attribute to point at a certain loop.

Please note the related technique consisting of aliasing a "break" or a "continue" to point at an outer loop instead of the current loop:
```
until false
  push f.l 0
  set outer-break break
  until false
    push f.l 'a'
    outer-break 'x'
```


## pseudo-variable tag

```
set a []
sequence tag: 'alpha'
  sequence tag: 'bravo'
    push a tag.bravo
    push a t.alpha
null
```
Ends up with `[ [ '0_1_1' ], [ '0_1' ] ]` in the variable 'a', and yes, a tag may point at multiple nids (node identifiers).

