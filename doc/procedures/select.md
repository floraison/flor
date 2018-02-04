
# select, reject

Filters a collection

"select" and "reject" are the 'block-oriented' children of
"filter" and "filter-out" respectively.

```
select [ 1, 2, 3, 4, 5 ]
  = (elt % 2) 1

# f.ret --> [ 1, 3, 5 ]
```

Note that the equivalent "filter" is:
```
filter [ 1, 2, 3, 4, 5 ]
  def x
    = (x % 2) 1
```

The blocks understand `elt` (the current element), `idx` (the current
zero-based index), and `key` (the current key for an object/hash).

## with objects (hashes)

```
select { a: 'A', b: 'B', c: 'C', d: 'D' }
  key == 'a' or val == 'C' or idx == 3

# f.ret --> { 'a' => 'A', 'c' => 'C', 'd' => 'D' }
```

## reject

"reject" is the negative of "select".

```
reject [ 1, 2, 3, 4, 5 ]
  (elt % 2) == 0

# f.ret --> [ 1, 3, 5 ]
```

## iterating blocks

Iterating blocks are given 3 to 4 local variables.

A block iterating over an array will receive `elt` (the current element
of the iteration), `idx` (the zero-based index of the current element),
and `len` (the length of the array).

A block iterating over an object will receive `key` (the current string
key), `val` (the current value), `idx` (the zero-based index of the
current key/val), and `len` (the length of the object).

## see also

[filter](filter.md), [map](map.md), [reject](select.md), and [collect](collect.md).


* [source](https://github.com/floraison/flor/tree/master/lib/flor/pcore/select.rb)
* [select spec](https://github.com/floraison/flor/tree/master/spec/pcore/select_spec.rb)

