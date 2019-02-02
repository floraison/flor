
# concurrence

Executes its children concurrently.

```
concurrence
  #
  # 'alpha' and 'bravo' will be tasked concurrently.
  #
  task 'alpha'
  task 'bravo'
  #
  # this concurrence will reply to its parent node when 'alpha' and 'bravo'
  # will both have replied.
```

## payload merging

by default, all the children replies are merged, with the first to
reply having the upper hand.
```
concurrence
  set f.a 0
  set f.a 1
  set f.b 2
# will result in a payload of { a: 0, b: 2 } (first child replies first
# in those simplistic settings)
```

## the expect: attribute

Tells the concurrence how many children replies are expected at most.
Once that could is reached, remaining children are cancelled by default.
```
concurrence expect: 1
  set f.a 0
  set f.b 1
```

## the remaining: attribute

As seen above, `expect:` will let the concurrence cancel the children
that have not yet replied once the expected count is reached.
With `remaining:` one can tell the concurrence to simply forget them,
they will go on and their, future, reply will be discarded (the concurrence
being already gone).

`remaining:` may be shortened to `rem:`.

```
concurrence expect: 1 rem: 'forget'
    #
    # will forget child 'alpha' as soon as child 'bravo' replies,
    # and vice versa.
    #
  task 'alpha'
  task 'bravo'
```

```
concurrence expect: 1 rem: 'wait'
    #
    # if 'alpha' replies before 'bravo', the concurrence will wait for
    # 'bravo', without cancelling it. And vice versa.
    #
  task 'alpha'
  task 'bravo'
```

## on_receive: / receiver:

Sets a function that is to be run each time a concurrence branch replies.
Should return a boolean, `true` for the concurrence to end (and trigger
the merging) or `false` for the concurrence to go on (and replies from
other branches to be received).

In this example, the receiver is actually an implementation of the default
receive behaviour, "concurrence" merges as soon as all the children have
replied (`>= (length replies) branch_count`).
```
define r reply, from, replies, branch_count
  >= (length replies) branch_count
concurrence on_receive: r
  + 1 2
  + 3 4
```

The receiver can be used to change the reply payload. Instead of
returning a boolean, it can return an object with the `done:` and
the `payload:` keys:
```
define r reply, from, replies, branch_count, over
  set reply.ret (+ reply.ret 10)
  { done: (>= (length replies) branch_count), payload: reply }
concurrence on_receive: r
  + 1 2
  + 3 4
```
The first branch thus returns `1 + 2 + 10`, while the second one returns
`3 + 4 + 10`.

## on_receive (non-attribute)

Sometimes, it's better to declutter the concurrence and write the
on_receive as a 'special' child rather than a attribute:

```
define r reply, from, replies, branch_count
  >= (length replies) branch_count
concurrence on_receive: r
  + 1 2
  + 3 4
```
becomes
```
concurrence tag: 'x'
  on_receive (def \ >= (length replies) branch_count)
  + 12 34
  + 56 78
```
One can even express the function has a 'block':
```
concurrence tag: 'x'
  on_receive
    >= (length replies) branch_count
  + 12 34
  + 56 78
```

## on_merge: / merger:
## on_merge (non-attribute)
## child_on_error: / children_on_error:
## child_on_error / children_on_error (non-attribute)


* [source](https://github.com/floraison/flor/tree/master/lib/flor/punit/concurrence.rb)
* [concurrence spec](https://github.com/floraison/flor/tree/master/spec/punit/concurrence_spec.rb)

