
# select

Filters a collection
```
select [ 1, 2, 3, 4, 5 ]
  = (elt % 2) 1

# f.ret --> [ 1, 3, 5 ]
```

## with objects (hashes)

```
select { a: 'A', b: 'B', c: 'C', d: 'D' }
  key == 'a' or val == 'C' or idx == 3

# f.ret --> { 'a' => 'A', 'c' => 'C', 'd' => 'D' }
```

## see also

[filter](filter.md), [map](map.md) and [collect](collect.md).


* [source](https://github.com/floraison/flor/tree/master/lib/flor/pcore/select.rb)
* [select spec](https://github.com/floraison/flor/tree/master/spec/pcore/select_spec.rb)

