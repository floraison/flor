
# cancelling.md

One can tell a flor instance to cancel an execution or part of it.

Any [cancel handler](on_cancel.md) present is triggered.

A variant of cancelling is killing. It's mostly like cancelling, but cancel handlers do not get triggered.


## cancelling an execution

```ruby
exid = FLOR.launch(%{ stall _ })
  #
  # A simplistic workflow definition, it simply stalls immediately.
  # That makes

# ...

FLOR.cancel(exid)
```


## cancelling part of an execution

TODO


## cancel handlers

A branch may react upon getting cancelled.

TODO


## killing an execution or part of it

TODO


## waiting for the cancellation to complete

TODO


## taskers and cancellation

TODO

