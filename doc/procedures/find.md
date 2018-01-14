
# find

Finds the first matching element.

```
find [ 1, 2, 3 ]
  def elt
    (elt % 2) == 0
# f.ret --> 2
```

With objects (maps), it returns the first matching entry (pair).
```
find { a: 'A', b: 'B', c: 'C' }
  def key, val
    val == 'B'
# f.ret --> [ 'b', 'B' ]
```

## see also

[Map](map.md) and [detect](detect.md), [any?](any.md).


* [source](https://github.com/floraison/flor/tree/master/lib/flor/pcore/find.rb)
* [find spec](https://github.com/floraison/flor/tree/master/spec/pcore/find_spec.rb)

