
# hooks

Hooks are pieces of code that are run before or after the flor executor consumes a message.

Hooks are external to flor definitions or executions, they are triggered for any matching message, whatever the execution. [Traps](traps.md) are set by executions and generally terminate when their execution terminates.

## setting a hook programmatically

```ruby
flor = Flor::Unit.new('envs/test/etc/conf.json')
# ...
flor.hooker.add('journal', Flor::Journal)
```

The [journal](../lib/flor/unit/journal.rb) is a minimal example of hook. It's used in spec to track messages emitted by test executions.

TODO setting a block hook

TODO

## setting a hook via the configuration

TODO

