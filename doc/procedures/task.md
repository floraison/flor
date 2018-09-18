
# task

Tasks a tasker with a task.

```
task 'clean up' by: 'alan'
task 'clean up' for: 'alan'
task 'clean up' assign: 'alan'
task 'alan' with: 'clean up'
alan task: 'clean up'  # {tasker} task: {taskname}
task 'alan'
# ...
```

Note that the quotes are the tasker name can be omitted:
```
task 'clean up' by: alan
task 'clean up' for: alan
task 'clean up' assign: alan
task alan with: 'clean up'
alan task: 'clean up'  # {tasker} task: {taskname}
task alan
# ...
```

Tasking hands a task (a message hash serializable to JSON) to a tasker.
See [tasks](../tasks.md) for more information.

Since routing tasks among taskers is flor essential "task", this "task"
procedure is very important.

Note that "task" can be implicit, as in:
```
alan task: 'clean up'
```


* [source](https://github.com/floraison/flor/tree/master/lib/flor/punit/task.rb)
* [task spec](https://github.com/floraison/flor/tree/master/spec/punit/task_spec.rb)

