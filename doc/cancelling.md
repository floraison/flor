
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

There are a couple of `Flor::Scheduler#wait` calls. They are commented out, they'd be necessary if the example were self-contained, I commented out instead of putting ellipses. They should be seen as "change of context". An execution is launched from an HTTP request controller, later on, it gets cancelled from antor request controller.


## cancelling an execution

```ruby
# launch a simplistic workflow execution, that just stalls immediately
exid =
  FLOR.launch(%q{
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
  FLOR.launch(%q{
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
  # cancel the first "stall"

#FLOR.wait(exid, '0 receive')
  # wait until the cancelled "stall" replies to its parent "concurrence" at '0'

p FLOR.executions[exid: exid].nodes.keys
  # => [ '0', '0_1' ]
  #    the '0_0' branch got cancelled
```


## cancel handlers

A branch may react upon getting cancelled.

In this example, the `on_cancel:` just sets the field `got_cancelled` to true in the resulting payload:
```ruby
exid =
  FLOR.launch(%q{
    sequence on_cancel: (def \ set f.got_cancelled true)
      stall _
  })

#FLOR.wait(exid, '0_0 receive')
  # wait until _ has replied to its parent "stall"

FLOR.cancel(exid, '0', payload: {})

m = FLOR.wait(exid, 'terminated')
  # wait until the execution terminates and capture the resulting
  # 'terminated' message

p m['point']                     # ==> terminated
p m['payload']['got_cancelled']  # ==> true
```

Read about setting cancel handlers in [on_cancel / on cancel](on_cancel.md).


## killing an execution or part of it

TODO


## waiting for the cancellation to complete

TODO


## taskers and cancellation

When the node of a tasker invocation gets cancelled, the tasker itself receives a 'detask' message. Flor then proceeds to call the `#cancel` method of the tasker. If it's not present, it searches for `#detask` or `#on_cancel`.

Here is a fictitious tasker implementation. It expects to be bound behind the usernames of the AcmeApp. Upon receiving a task, it creates a workitem then notifies the user. When the user is done with the app, she/he can call the `#on_task_done` method which replies to flor. When the branch of execution to which our task/workitem belongs gets cancelled, flor arranges for `#on_cancel` to be called. The Tasker implementation is responsible for cleaning up its side (here cancelling the workitem and notifying the user) and replying when this is done.
```ruby
class AcmeApp::UserTasker < Flor::BasicTasker

  def on_task

    u = lookup_user
    wi = AcmeApp::WorkItem.create(message, u)
    AcmeApp.notify(u.email, 'new workitem in', wi)

    []
  end

  def on_cancel

    u = lookup_user
    wi = AcmeApp::WorkItem.cancel(message, u)
    AcmeApp.notify(u.email, 'workitem cancelled', wi)

    reply(set: { cancelled_workitem_id: wi.id })
  end

  def on_task_done(workitem)

    reply(set: { done_workitem_id: workitem.id })
  end

  protected

  def lookup_user
    AcmeApp.lookup_user(tasker)
  end
end
```

If the tasker implementation doesn't respond to `#on_detask`, `#detask`, `#on_cancel`, `#cancel`, or the generic `#on_message` or `#on`, an error will be launched and the flow will stall. It's thus a good idea to have an `#on_cancel` implementation for such taskers, those that "hoard" the task for a while, not immediately doing something quick with it and replying.

