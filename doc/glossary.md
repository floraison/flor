
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
## executor
## hook
## loader
## message
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

