
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

## see also

[find](find.md).


* [source](https://github.com/floraison/flor/tree/master/lib/flor/pcore/detect.rb)
* [detect spec](https://github.com/floraison/flor/tree/master/spec/pcore/detect_spec.rb)

