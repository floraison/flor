
# hooker service

The hooker is handed every messages an execution receives or emits. It then passes those messages to the hooks that have registered for them.

For example, a hook might be interested in seeing all the "launch" messages before they are treated or right after.

The hooker manages the hook registrations and hands them messages.

Hooks are registered in the hooker in two ways: via configuration and via direct, programming, registration.

TODO


## links

* [source](../lib/flor/unit/hooker.rb)
* [conf hook spec](../spec/unit/conf_hooks_spec.rb)
* [unit hook spec](../spec/unit/unit_hooks_spec.rb)

