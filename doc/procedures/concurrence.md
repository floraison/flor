
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
  task 'alpha'
  task 'bravo'
# will forget child 'alpha' as soon as child 'bravo' replies,
# and vice versa.
```


* [source](https://github.com/floraison/flor/tree/master/lib/flor/punit/concurrence.rb)
* [concurrence spec](https://github.com/floraison/flor/tree/master/spec/punit/concurrence_spec.rb)

