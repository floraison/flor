
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

# TODO document "kill"
# TODO document "on_cancel"


* [source](https://github.com/floraison/flor/tree/master/lib/flor/punit/cancel.rb)
* [cancel spec](https://github.com/floraison/flor/tree/master/spec/punit/cancel_spec.rb)

