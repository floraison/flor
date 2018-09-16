
# map

This is the classical "map" procedure. It accepts a collection
and a function and yields a new collection.

```
map [ 1, 2, 3 ]
  def x
    + x 3
# f.ret yields [ 4, 5, 6 ]
```

The collection if not given is taken from `f.ret`:
```
[ 1, 2, 3 ]
map
  def x
    + x 2
# f.ret yields [ 3, 4, 5 ]
```

The function may be given by reference:
```
define add3 x
  + x 3
map [ 0, 1 ] add3
```

There is an implicit `idx` var:
```
map [ 'a', 'b' ]
  def x \ [ idx, x ]
# f.ret yields [ [ 0, 'a' ], [ 1, 'b' ] ]
```
but that index can be included in the function signature:
```
map [ 'a', 'b' ]
  def x i \ [ x, i ]
# f.ret yields [ [ 'a', 0 ], [ 'b', 1 ] ]
```

## with objects (hashes)

```
map { a: 'A', b: 'B', c: 'C' }
  def k v \ [ k v ]
# f.ret --> [ [ 'a', 'A' ], [ 'b', 'B' ], [ 'c', 'C' ] ]

map { a: 'A', b: 'B', c: 'C' }
  def k v i \ [ i k v ]
# f.ret --> [ [ 0, 'a', 'A' ], [ 1, 'b', 'B' ], [ 2, 'c', 'C' ] ]
```

## iterating and functions

Iterating functions accept 0 to 3 arguments when iterating over an
array and 0 to 4 arguments when iterating over an object.

Those arguments are `[ value, index, length ]` for arrays.
They are `[ key, value, index, length ]` for objects.

The corresponding `key`, `val`, `idx` and `len` variables are also
set in the closure for the function call.

## missing collection

"map" fails if it is not given a collection.

## missing function

"map" returns the collection as is if it is not given a function.

## see also

[Collect](collect.md), [cmap](cmap.md).


* [source](https://github.com/floraison/flor/tree/master/lib/flor/pcore/map.rb)
* [map spec](https://github.com/floraison/flor/tree/master/spec/pcore/map_spec.rb)

