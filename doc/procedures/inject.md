
# inject

Inject is a simplified version of [reduce](reduce.md).

Inject takes a collection and a block. It reduces the collection
to a single result thanks to the block.

The block is run for each element in the collection, it's passed
`res` and `elt`. `res` is the result, the accumulator, `elt`
is the current element in the collection.

The block must return the result for the next iteration.

```
inject [ '0', 1, 'b', 3 ]
  res + elt
# --> "01b3"
```

An initial value is accepted (generally after the collection)

```
inject [ 0, 1, 2, 3, 4 ] 10
  res + elt
# --> 20
```

## see also

[Reduce](reduce.md).


* [source](https://github.com/floraison/flor/tree/master/lib/flor/pcore/inject.rb)
* [inject spec](https://github.com/floraison/flor/tree/master/spec/pcore/inject_spec.rb)

