
# shuffle, sample

Returns a shuffled version of an array.

## shuffle

```
shuffle [ 0 1 2 3 4 ]
  # might set [ 3 2 0 1 4 ] in f.ret
shuffle [ 0 1 2 3 4 ] 2
  # might set [ 4 2 ] in f.ret
shuffle [ 0 1 2 3 4 ] count: 2
  # might set [ 4 2 ] in f.ret

[ 0 1 2 3 4 ]
shuffle _
  # might set [ 4 0 2 1 3 ] in f.ret
```

## sample

When given a count integer, "sample" behaves exactly like "shuffle".
When not given a count, it returns a single, random, element of the given
array.

```
sample [ 'a' 'b' 'c' ]
  # might set 'b' in f.ret

[ 'a' 'b' 'c' ]
sample _
  # might set 'b' in f.ret

sample [ 'a' 'b' 'c' ] 2
  # might set [ 'c', 'b' ] in f.ret
```

## see also

[Slice](slice.md), [index](slice.md), and [length](length.md)


* [source](https://github.com/floraison/flor/tree/master/lib/flor/pcore/shuffle.rb)
* [shuffle spec](https://github.com/floraison/flor/tree/master/spec/pcore/shuffle_spec.rb)

