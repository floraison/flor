
# filter, filter-out

Filters a collection

```
filter [ 1, 2, 3, 4, 5 ]
  def x
    = (x % 2) 1

# f.ret --> [ 1, 3, 5 ]
```

## with objects (hashes)

```
filter { a: 'A', b: 'B', c: 'C', d: 'D' }
  def k v i
    #or (k == 'a') (v == 'C') (i == 3)
    k == 'a' or v == 'C' or i == 3

# f.ret --> { 'a' => 'A', 'c' => 'C', 'd' => 'D' }
```

## filter-out

Is the negative sibling of "filter".

```
filter-out [ 1, 2, 3, 4, 5 ]
  def x
    = (x % 2) 0

# f.ret --> [ 1, 3, 5 ]
```

## see also

[map](map.md), [select](select.md), and [reject](select.md).


* [source](https://github.com/floraison/flor/tree/master/lib/flor/pcore/filter.rb)
* [filter spec](https://github.com/floraison/flor/tree/master/spec/pcore/filter_spec.rb)

