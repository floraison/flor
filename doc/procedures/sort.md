
# sort

Sorts an array or an object.

"sort" takes an array or an object and sorts its content.

```
sort [ 0 7 1 5 3 4 2 6 ]
  # => [ 0 1 2 3 4 5 6 7 ]
```

Without a function, "sort" uses the underlying (Ruby) sort methods.

One can use a function to sort in specific ways:
```
[ { name: 'Alice', age: 33, function: 'ceo' }
  { name: 'Bob', age: 44, function: 'cfo' }
  { name: 'Charly', age: 27, function: 'cto' } ]
sort (def a b \ - a.age b.age)
```

The function should return a boolean or a number. `true` or a negative
number indicates `a` comes  before `b`, anything else indicates `a`
comes after `b`.

## behind the scenes

Sorting an array results in a sorted array stored in `f.ret`, sorting
an object results in a sorted (entries) object stored in `f.ret`.

Using a function to sort is quite slow. Behind the scene a quicksort is
used, to lower the number of calls to the sort function, but since
the function is a flor function, calls are quite costly.
By default, "sort" will cache the call results. For example, upon
comparing 1 with 7, the results will be cached (the 7 vs 1 will be cached
as well).

It's OK to disable this caching:
```
sort memo: false a (def a b \ < a b)
```
(but why should we need that?)

## see also

[sort_by](sort_by.md), [reverse](reverse.md), and [shuffle](shuffle.md)


* [source](https://github.com/floraison/flor/tree/master/lib/flor/pcore/sort.rb)
* [sort spec](https://github.com/floraison/flor/tree/master/spec/pcore/sort_spec.rb)

