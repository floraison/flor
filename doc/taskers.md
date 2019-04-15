
# taskers

A tasker is a piece of code that, upon receiving a task from flor, performs some work and then hands back the task with updated information to flor.

A tasker might do its job in the same Ruby process as the flor worker that invoked it, or it might call some external process.

An external service could be called and the tasker might reply only when the result is available. [Timeouts](on_timeout.md) could come in handy here.

## taskers and the default loader (directory configuration)

TODO


## taskers and the HashLoader

TODO

### taskers as Ruby blocks

When using the `HashLoader`, one can add a tasker directly, with a Ruby block.

```ruby
FLOR = Flor::Unit.new(loader: Flor::HashLoader, sto_uri: 'sqlite:/')
FLOR.add_tasker('clerk') { payload['ret'] = 'Kilroy was here' }
```

This is suitable only for blocks that perform quick operations on the payload and return immediately.


## Ruby template for a tasker

```ruby
class MyTasker < Flor::BasicTasker

  def on_task
  end

  def on_cancel
  end
end
```


## domain taskers and taskers

TODO


## taskers and errors

TODO

