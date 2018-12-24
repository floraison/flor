
# sort_by

Takes a collection and a function and returns the collection
sorted by the value returned by the function.

```
sort_by [ { n: 1 } { n: 0 } { n: 4 } { n: 7 } ] (def e \ e.n)
  # OR
sort_by (def e \ e.n) [ { n: 1 } { n: 0 } { n: 4 } { n: 7 } ]
  #
  # => [ { 'n' => 0 }, { 'n' => 1 }, { 'n' => 4 }, { 'n' => 7 } ]
```

## function parameters

If the collection is an array, the function signature may look like:
```
def f(elt, idx, len)
  # elt: the element
  # idx: the index of the element (an integer starting at 0)
  # len: the length of the array being sorted
```
If the collection is an object:
```
def f(key, val, idx, len)
  # key: the key for the entry
  # val: the value for the entry
  # idx: the index of the entry (an integer starting at 0)
  # len: the number of keys/entries in the object
```

Once the function has returning what value to rank/sort by, the
sorting is done behind the scene by a (Ruby) sort. If the
values returned are heterogeneous, the values are turned into
their JSON representation before the sorting happens.

## see also

[sort](sort.md), [reverse](reverse.md), and [shuffle](shuffle.md)


* [source](https://github.com/floraison/flor/tree/master/lib/flor/pcore/sort_by.rb)
* [sort_by spec](https://github.com/floraison/flor/tree/master/spec/pcore/sort_by_spec.rb)

