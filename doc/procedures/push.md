
# push, pushr

Pushes a value into an array (in a variable or a field).

```
sequence
  set a []
  set f.a []
  push a 1
  push f.a 2
```

```
sequence
  set o { a: [], b: 3 }
  7
  push o.a  # will push value 7 (payload.ret) into array at 'o.a'
```

```
push
  myarray    # the 1st child is expected to hold the reference to the array
  do_this _
  do_that _
  + 1 2      # the last child should hold the value to push
```

## "pushr"

Following ["set"](set.md) and "setr", "push", upon beginning its execution
will keep the incoming payload.ret and restore it to that value right
before finishing its execution. "pushr" will not do that, it will leave
the payload.ret as is, that is, set to the value that was just pushed to
the array.


* [source](https://github.com/floraison/flor/tree/master/lib/flor/pcore/push.rb)
* [push spec](https://github.com/floraison/flor/tree/master/spec/pcore/push_spec.rb)

