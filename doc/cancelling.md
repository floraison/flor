
# cancelling.md

One can tell a flor instance to cancel an execution or part of it.

Any [cancel handler](on_cancel.md) present is triggered.

A variant of cancelling is killing. It's mostly like cancelling, but cancel handlers do not get triggered.

The code examples in this page assume a `FLOR` constant pointing to an flor scheduler instance. Something like:
```ruby
require 'flor/unit'
FLOR = Flor::Unit.new(loader: Flor::HashLoader, sto_uri: 'sqlite:/')
FLOR.storage.delete_tables  #
FLOR.storage.migrate        # prepare the database
FLOR.start                  # start the the scheduler
```

There are a couple of [wait](procedures/wait.md) calls. They are commented out, they'd be necessary if the example were self-contained, I commented out instead of putting ellipses. They should be seen as "change of context". An execution is launched from an HTTP request controller, later on, it gets cancelled from antor request controller.


## cancelling an execution

```ruby
# launch a simplistic workflow execution, that just stalls immediately
exid =
  FLOR.launch(q%{
    stall _
  })

# ...

FLOR.cancel(exid)

# ...

p FLOR.executions[exid: exid].status
  # ==> 'terminated'
```


## cancelling part of an execution

```ruby
exid =
  FLOR.launch(%{
    concurrence
      stall tag: 'x'
      stall tag: 'y'
  })

#FLOR.wait(exid, '0_1 receive')
  # wait until the second "stall" receives from its "tag"

p FLOR.executions[exid: exid].nodes.keys
  # => [ '0', '0_0', '0_1' ]
  #    the execution has a root ('0') and two branches ('0_0', '0_1')

FLOR.cancel(exid, '0_0')
  # cancel

#FLOR.wait(exid, '0 receive')
  # wait until

p FLOR.executions[exid: exid].nodes.keys
  # => [ '0', '0_1' ]
  #    the '0_0' branch got cancelled
```


## cancel handlers

A branch may react upon getting cancelled.

TODO


## killing an execution or part of it

TODO


## waiting for the cancellation to complete

TODO


## taskers and cancellation

TODO

