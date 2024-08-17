
# glossary.md

## attributes

Read more at [attributes.md](attributes.md).

Throughout documentation (and commit messages), attributes are suffixed with a colon, like in `vars:` while procedures are surrounded by double quotes, like in `"sequence"`, simply "sequence".

## branch

Most likely, "branch of execution". As flor parses the workflow definitions to trees, those trees get executed.
```python
concurrence
  sequence 'blue customers'
    alice 'gather feedback'
    brad 'prepare meeting'
  sequence 'green customers'
    carla 'gather feedback'
    david 'prepare meeting'
```
In the code above, any subtree might be a "branch of execution". The "concurrence" has two branch of executions running concurrently, 'blue customers' and 'green customers'.

## caller

The flor component that reads hook or tasker configurations and runs Ruby classes or external scripts with the incoming messages (hooked messages or task messages).

## core

Core contains everything that makes the basic flor language interpreter. It's always executed in a single [run](#run) - always transient. As soon as there is a [timer](#timer) or a [trap](#trap) - something that would not be present in a vanilla interpreter - it goes into [unit](#unit). As such, the [storage](#storage) is not a "core" thing, it belongs to "unit".

## domain

A domain is a dot separated list of names `[a-zA-Z0-9]+`.

An [execution](#execution) lives in a domain. An execution may only affect itself and other executions in the same [domain branch](#domain_branch).

Examples of domains: `org.example`, `org.example.accounting`, `acme.executive`, `test.red`, `test.blue`, ...

`org.example.accounting` is a sub-domain of `org.example`.

## domain branch

A domain and all its sub-domains.

## environment

TODO

## execution

An execution is an instance of a flow or in other words a live occurrence of a process/workflow. It's identified by an [execution id](#exid) ([exid](#exid)).

## executor

When it receives a launch message thus calling for a new [execution](#execution) (think of it as a new instance) or a message for a currently sleeping execution, the [scheduler](#scheduler) will create an executor and hand it the messages for the execution to start/resume.

An executor will die (stop working) when there are no more messages for the execution (did it just terminate?). In addition, under certain conditions, it can die after a certain number of messages has been processed. Without this limit, an execution might monopolize heavily the resources available to the scheduler. Well, at least that's the reasoning behind the design decision.

If there is already an executor processing messages for the execution, the scheduler will not create a new one, it will simply queue the message for the executor to pick it up, sooner or later.

## exid

A unique identifier for a flor [execution](#execution). For example "test-u-20161204.2144.kawajabachu" identifies an instance of a certain flow. It uses the following format: `{fully.qualified.domain}-{unitname}-{yyyymmdd.hhmm.mnemo}`.

## fei

The combination `{exid}-{nid}`, designates a single node within a flow execution. (The fei concept was more important in ruote).

## field

An entry in a [payload](#payload).

Fields in the flor language are accessed with the `f.` or the `field.` prefix.

```
sequence
  set f.f0 'Lev Tolstoy'
  f.f0 # ==> places 'Lev Tolstoy' in the `ret` field
```

There is a special `ret` field, it carries the result of a [procedure](#procedure).

## flow

A \[business\] process definition or a flow for short. In flor, they are written in the flor language.

## function

A function groups a subtree in a reusable unit, generally available behind a name.

A function is defined with `define`. An anonymous function is defined with `def`.

```
define f x  #
  x + 3     #
f 5         # yields 8 in f.ret
```

```
find [ 1, 2, 3 ]    #
  def elt           # anonymous function as argument to "find"
    (elt % 2) == 1  #
                    #
                    # this "find" yields [ 1, 3 ] in f.ret
```

The backslash helps when making a function more compact:
```
find [ 1, 2, 3 ] (def elt \ (elt % 2) == 1)
```

```
set f
  def x
    x * 3
```
is equivalent to:
```
define f x
  x * 3
```
("def" sets the reference of the new function in f.ret, it gets picked by "set" and placed in the variable 'f')

Flor wants [functions](#function), [procedures](#procedure), and [taskers](#tasker) calls to look similar. A single way to call.

## ganger

The ganger is a component of the [scheduler](#scheduler). It's the middleman between flor and the taskers. British definition of the word: "the foreman of a gang of labourers."

The ganger receives the tasks from the flor executor, decides what tasker will be invoked and hands it the task.

## hook

A hook is a pair criteria/code. The [hooker](#hooker) sees each message emitted/consumed in the [executor](#executor) and triggers the matching hooks.

The code is usually Ruby code but it could be an external script (more costly to run).

Hooks can thus be used for specialised logging purposes, FIXME (continue me)

## hooker

The hooker is a [scheduler](#scheduler) component that gets notified for each message treated in the current [executor](#executor).

The hooker tracks a list of [hooks](#hook). Upon receiving a message, the hooker hands the message to each matching hook. The matching criteria are the message point, the execution domain, the tags, etc...

Hooks are added programmatically to the unit, or the hooker directly, or they are set via the [environment](#environment) with their code and configuration.

The hooker is also responsible for triggering [traps](#trap) (hooks and traps simply share the same hooker infrastructure).

Read more at [hooks.md](hooks.md).

## launch

Starting a workflow execution is called a "launch". The unit/scheduler method to start an execution is `#launch`.
```ruby
exid = flor.launch(
  %q{
    sequence
      alice 'hello' times: 2
      bob 'world'
  },
  payload: { log: [ "started at #{Time.now}" ] })
    # launch a new execution, one that chains alice and bob work
```
(taken from [quickstart0](quickstart0/)).

## loader

The loader is a [scheduler](#scheduler) component helping other components load their codes and libraries. It follows the [domain](#domain) and [sub-domain](#sub-domain) system to load only the codes accessible to a given domain.

Read more at [services/loader.md](services/loader.md).

## message

Flor is merely about emitting and processing messages within an execution.

An initial "execute" message will launch a new execution and further "execute" message will expand it by adding new nodes to it. When a node is done it sends a "receive" message back to its parent node.

Read more at [messages.md](messages.md).

### point: execute
### point: receive
### point: terminated
### point: ceased
### point: failed
### point: entered
### point: left
### point: task
### point: return

## node

A node is the data representation of an active [procedure](#procedure) of a flor [execution](#execution).

It has a [node id](#nid).

Read more at [node.md](node.md) and [nodes.md](nodes.md).

## nid

Or "node id".

A key for the node in its execution. Is of the form `/^\d+(_\d+)*$/`, the root node having the "0" nid.

A nid is implicitly suffixed with `-0`. Nids with a `-\d+` suffix may appear for loops and [branches](#branch) executing multiple times.

See [subnid](#subnid).

## payload

Most of the [messages](#message) and the "execute" and "receive" messages in particular have a payload.

A payload is a dictionary / hash. It corresponds to a Javascript object (keys are strings, values are JSON values).

Payloads entries are named [fields](#field).

## pointer

Flor maintains a :flor_pointers table. This table is used behind the `Flor::Execution#by_tag(tag_name)`, `#by_var(var_name, value=:no)`, and `#by_tasker(tasker_name, taskname=:no)`.

The table is populated automatically each time an execution enters or leaves a tag, sets or unsets a top-level variable (top level, is the root node level), and each time a task reaches a tasker or is returned by a tasker.

Querying the :flor_pointers table helps looking up executions in a given state, or, in a reverse way, determine the state of a given execution.

## procedure

Procedures are the basic building block of the flor language. Those were called "expressions" in ruote.

```
sequence
  task 'alice' 'look for a caterpillar'
  sleep '1w'
```

In this example, "sequence", "task" and "sleep" are procedures.

Throughout documentation (and commit messages), attributes are suffixed with a colon, like in `vars:` while procedures are surrounded by double quotes, like in `"sequence"`, simply "sequence".

## run

Each time an [executor](#executor) is instantiated to run one or more [messages](#message) for an [execution](#execution), it is called an "execution run" or a "run" for short. The lifecycle of an execution might comprise one or more runs. For example a simple execution containing only a `sleep` call will span two runs.

1. The first run reaches the sleep and sets a [timer](#timer) for it;
2. Then when the timer triggers, a new [executor](#executor) is instantiated and it performs the post-sleep portion which is the final run ending with a "terminated" message ending the execution.

## runner

(renamed to [caller](#caller), since "run" is an executor concept)

## scheduler

The scheduler is the flor component (daemon) that watches for incoming [messages](#message) and instantiates [executors](#executor) to act upon them. It's named after its main responsibility which is to schedule flor [executions](#execution) by instantiating [executors](#executors) to run them. A scheduler is composed of a [storage](#storage), a [hooker](#hooker), a [loader](#loader) and a [ganger](#ganger).

## storage

The flor component behind the [scheduler](#scheduler) that stores [messages](#message), [executions](#execution), [timers](#timer) and [traps](#traps).

It is mostly a wrapper around a [Sequel](https://github.com/jeremyevans/sequel) dataset.

## sub-domain

`org.example.shop` is a sub-domain to `org.example` which is a sub-domain to `org`.

See [domain](#domain).

## subnid

A nid like `0_0_1-1` is composed of the pure nid (`0_0_1`) and of subnid (`-1`). A nide like `0_0_1` only has a pure nid, but in reality, it has an implicit sub of `-0`.

Subnids bigger than 0 are useful in case of loops and function invocations.

```
loop
  bob 'gather information'
  break _ if f.enough_info
```
The node `0_0` points a bob, but in execution, each pass to bob gets a different subnid.

See [nid](#nid).

## task

A work item, as handed by flor to a [tasker](#tasker).

```
sequence
  concurrence
    task 'technician 1' 'check right motor'
    task 'technician 2' 'check left motor'
  task 'technician 1' 'check reservoir'
```

The "task" [procedure](#procedure) is used to emit tasks from flor [executions](#execution).

## tasker

A piece of (usually Ruby) code in charge of taking an action based on a flor task handed to it.

Taskers or pointers to them are found (by the [loader](#loader) in the `lib/` directory of a flor [environment](#environment). There is actually a [ganger](#ganger) between the loader and the tasksers, it ultimately decides which tasker gets handed the task.

## timer

A timer is the data structure used by flor to keep track of time triggers. It corresponds to a "flor_timers" SQL table. Basically, flor keeps there a message serialized as JSON and the time at which this message has to be queued for execution.

Flor uses timers for procedures like [schedule](procedures/schedule.md), [cron](procedures/cron.md), and for the [timeout](#timeout) system.

## timeout

TODO

## trap

TODO

## tree

TODO

## unit

It could have been named an "engine", it got named an "unit". It's the set of flor services that work together to run flow executions.

It's usually instantatied via something like
```ruby
FLOR = Flor::Unit.new('envs/test/etc/conf.json')
```
that is pointing to the configuration file for a given flor [environment](#environment).

[Multiple units](multi_instance.md) may share the same database and thus work together on making the executions progress.

## variable

Flor has [fields](#fields) in the [payload](#payload) found in the messages it passes from [tasker](#tasker) to tasker (from [procedure](#procedure) to procedure).

It also has variables. Whereas fields are seen by taskers, variables stay in the execution.

```
sequence
  set a 'alpha'
  set f.a 'allegro'
  task 'alice'
    # the task handled to Alice will mostly look like { 'a' => 'allegro' }
```

Variables are mostly used as information for flow control and as [function](#function) parameters/arguments. It's easy to copy values from and back variables and fields with [set](procedures/set.md).

Note that a tasker may be presented the variables as seen in its execution branch if its configuration sports `include_vars: true`.

Read more about [variables](variables.md).

