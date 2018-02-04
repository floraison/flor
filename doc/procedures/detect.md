
# detect

Detect is a simplified version of [find](find.md).

```
detect [ 1, 2, 3 ]
  (elt % 2) == 0
# f.ret --> 2
```

With objects (maps), it returns the first matching entry (pair).
```
detect { a: 'A', b: 'B', c: 'C' }
  val == 'B'
# f.ret --> [ 'b', 'B' ]
```

## iterating blocks

Iterating blocks are given 3 to 4 local variables.

A block iterating over an array will receive `elt` (the current element
of the iteration), `idx` (the zero-based index of the current element),
and `len` (the length of the array).

A block iterating over an object will receive `key` (the current string
key), `val` (the current value), `idx` (the zero-based index of the
current key/val), and `len` (the length of the object).

## see also

[find](find.md).


* [source](https://github.com/floraison/flor/tree/master/lib/flor/pcore/detect.rb)
* [detect spec](https://github.com/floraison/flor/tree/master/spec/pcore/detect_spec.rb)

