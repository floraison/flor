
# glossary.md

## core

As opposed to [unit](#unit). The basics of flor, everything that makes it a basic flor language interpreter. Core flor executions always execute in a single [run](#run). As soon as there is a [timer](#timer) or a [trap](#trap), something that would not be present in a vanilla interpreter, it goes into "unit".

The [storage](#storage) is not a "core" thing, it belongs to "unit". Core flor concepts are transient.

## domain

A domain is a dot separated list of names `[a-zA-Z0-9]+`.

An [execution](#execution) lives in a domain. An execution may only affect itself and other executions in the samed [domain branch](#domain_branch).

## domain branch

A domain and all its sub domains.

## execution

An execution is a live instance of a process or workflow (depending on your point of view). It's flagged with an [execution id](#exid) or [exid](#exid) for short.

## executor

When it receives a launch message (calling for a new [execution](#execution)) or a message for a currently sleeping execution, the [scheduler](#scheduler) will create an executor and hand it the messages for the execution.

An executor will stop working when there are no more messages for the execution (did it just terminate?) or if a certain number of messages has been processed (without this limit, an execution might monopolize heavily the resources available to the scheduler, well at least that's the reasoning behind the design decision).

If there is already an executor processing messages for the execution, the scheduler will not create a new one, it will simply queue the message for the executor to pick it up, sooner or later.

## exid

A unique identifier for a flor [execution](#execution), for example "test-u-20161204.2144.kawajabachu".

Its format is "{fully.qualified.domain}-{unitname}-{yyyymmdd.hhmm.mnemo}".

## expression
## hook
## loader

## message

Flor is merely about emitting and processing messages within an execution.

An initial "execute" message will launch a new execution and further "execute" message will expand it by adding new nodes to it. When a node is done it sends a "receive" message back to its parent node.

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
## payload
## procedure

## run

Each time an [executor](#executor) is instantiated to run one or more [messages](#message) for an [execution](#execution), the session is called an "execution run" or a "run" for short.

The lifecycle of an execution might comprise one or more runs. For example a simple execution containing only a `sleep` call will span two runs. The first run reaches the sleep and sets a [timer](#timer) for it, then when the timer triggers, an executor is instantiated and it performs the post-sleep, final run ending with a "terminated" message for the execution.

## scheduler
## storage
## task
## tasker
## timer
## trap
## unit
## variable

