
# noeval

Immediately replies, children are not evaluated

```
sequence
  1
  noeval
    true
    [ 1, 2, 3 ]
  # f.ret is still 1 here, not [ 1, 2, 3 ]
```


* [source](https://github.com/floraison/flor/tree/master/lib/flor/pcore/noeval.rb)
* [noeval spec](https://github.com/floraison/flor/tree/master/spec/pcore/noeval_spec.rb)

