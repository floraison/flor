
# cancel, kill

Cancels an execution branch

```
concurrence
  sequence tag: 'blue'
  sequence
    cancel ref: 'blue'
```
You can drop the `ref:`
```
concurrence
  sequence tag: 'blue'
  sequence
    cancel 'blue'
```

It's also OK to use nids directly:
```
concurrence         # 0
  sequence          # 0_0
    # ...
  sequence          # 0_1
    cancel nid: '0_0'
      # or
    #cancel '0_0'
```
But it's kind of brittle compared to using tags.

## kill

"kill" is equivalent to "cancel", but once called, cancel handlers are
ignored, it cancels through.


## see also

[On_cancel](on_cancel.md), [on](on.md)


* [source](https://github.com/floraison/flor/tree/master/lib/flor/punit/cancel.rb)
* [cancel spec](https://github.com/floraison/flor/tree/master/spec/punit/cancel_spec.rb)

