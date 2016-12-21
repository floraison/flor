
# loop

Executes child expressions in sequence, then loops around.

It's mostly a [cursor](cursor.md) that loops upon going past its
last child.

```
loop
  task 'alpha'
  task 'bravo'
```

Accepts `break` and `continue` like `cursor` does.


* [source](https://github.com/floraison/flor/tree/master/lib/flor/pcore/loop.rb)
* [loop spec](https://github.com/floraison/flor/tree/master/spec/pcore/loop_spec.rb)

