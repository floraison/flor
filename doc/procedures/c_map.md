
# cmap, c-map

Concurrent version of "map". Spins a concurrent child for each
element of the incoming/argument collection.

```
cmap [ 1 2 3 ]
  def x \ * x 2
# yields: [ 2, 4, 6 ]

[ 1 2 3 ]
cmap (def x \ * x 2)
# yields: [ 2, 4, 6 ]

define double x \ * x 2
cmap double [ 1 2 3 ]
# yields: [ 2, 4, 6 ]
```

"cmap" is over when all the children have answered. For more complex
concurrent behaviours, look at [concurrence](concurrence.md).

## see also

[Map](map.md), [concurrence](concurrence.md).


* [source](https://github.com/floraison/flor/tree/master/lib/flor/punit/c_map.rb)
* [c-map spec](https://github.com/floraison/flor/tree/master/spec/punit/c_map_spec.rb)

