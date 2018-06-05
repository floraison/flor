
# tasks

At its core, flor is an interpreter. It reads flow definitions written in the flor language and interprets them. Those flow definitions are ultimately about handing tasks to participants. Those participants are called "taskers". Usually they are pieces of Ruby code that take as input a Ruby hash, perform some work and hand it back.

The easiest way to hand a task to tasker is to use the "task" procedure:
```
sequence
  task 'alice' 'phase 1'
  task 'bob' 'phase 2'
```

It's OK to "hide" the "task" and write:
```
sequence
  alice 'phase 1'
  bob 'phase 2'
```

## tasker

A tasker is a piece of code that, upon receiving a task from flor, performs some work and then hands back the task with updated information to flor.

Usually, taskers are pieces of Ruby code, but that can be broadened.

## ganger

Between the flor executor and the taskers sits the ganger. In fact, the executor hands the task to the ganger and it then decides which tasker gets the task.

## environment

TODO

