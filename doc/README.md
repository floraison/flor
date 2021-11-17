
# flor

Flor is a Ruby workflow engine.

It interprets a language describing "workflows". They can be thought of long-running programs meant for orchestrating work among participants \[in workflows\].

Here are a few entry points into the documentation:

* [glossary](glossary.md)
* [messages](messages.md)
* [language](language.md)
* [procedures](procedures/)
* [services](services/)
* [workflow control patterns](patterns.md)

If you have any question feel free to ask in the [flor chat room](https://gitter.im/floraison/flor).


## pieces of documentation

* [blocks.md](blocks.md) - flor blocks vs Ruby blocks
* [cancelling.md](cancelling.md) - cancelling or killing an execution or part of it
* [chaining.md](chaining.md) - piping/chaining procedure calls
* [common_attributes.md](common_attributes.md) - attributes common to all procedures
* [domains.md](domains.md) - the flor domain layering system
* [fragments.md](fragments.md) - (fragments of documentation to be moved later on)
* [glossary.md](glossary.md) - flor terms with short explanations
* [hooks.md](hooks.md) - hooking pieces of code to react on flor execution events
* [language.md](language.md) - discussing the flor language
* [launching.md](launching.md) - launching flor executions from Ruby or by inserting launch messages in the flor database
* [messages.md](messages.md) - the messages whose back and forth make up flor executions
* [multi_instance.md](multi_instance.md) - flor instances collaborating to process executions across Ruby processes
* [node.md](node.md) - each flor procedure is backed by a node
* [nodes.md](nodes.md) - flor nodes and their interactions
* [on_cancel.md](on_cancel.md) - tying "on cancel" handlers to flor nodes
* [on_error.md](on_error.md) - tying "on error" handlers to flor nodes
* [on_receive.md](on_receive.md) - tying "on receive" handlers to flor nodes
* [on_timeout.md](on_timeout.md) - tying "on timeout" handlers to flor nodes
* [patterns.md](patterns.md) - flor in the light of the [workflow patterns](http://www.workflowpatterns.com)
* [patterns__control_flow.md](patterns__control_flow.md) - workflow control flow patterns
* [patterns__data.md](patterns__data.md) - workflow data patterns
* [patterns__exception_handling.md](patterns__exception_handling.md) - workflow exception handling patterns
* [patterns__resource.md](patterns__resource.md) - workflow resource patterns
* [re_applying.md](re_applying.md) - cancelling part of an execution to force it to a new definition tree
* [recipes.md](recipes.md) - good/best practices
* [signalling.md](signalling.md) - sending a signal to an execution (to trigger a reaction)
* [strings.md](strings.md) - dealing with strings in the flor language
* [tags.md](tags.md) - the `tag:` attribute and its uses
* [tasks.md](tasks.md) - handing tasks to gangers and taskers
* [traps.md](traps.md) - setting event traps in flor definitions
* [variables.md](variables.md) - the flor language and variables
* [procedures/](procedures) - documentation directory for flor procedures
* [services/](services) - pieces of documentation about flor services
* [quickstart0/](quickstart0) - flor one file quickstart
* [quickstart1/](quickstart1) - flor quickstart with a flor directory tree

