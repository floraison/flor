
# collect

Collect is a simplified version of [map](map.md).

```
map [ 1, 2, 3 ]
  def x
    + x 3
  #
  # becomes
  #
collect [ 1, 2, 3 ]
  + elt 3
```
Collect accepts, instead of a function, a block, where `elt` contains
the current element and `idx` the current index.

```
collect [ 'a', 'b' ]
  [ idx, elt ]
```

## see also

[Map](map.md).


* [source](https://github.com/floraison/flor/tree/master/lib/flor/pcore/collect.rb)
* [collect spec](https://github.com/floraison/flor/tree/master/spec/pcore/collect_spec.rb)

