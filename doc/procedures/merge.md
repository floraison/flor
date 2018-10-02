
# merge

Merges objects or arrays.

With objects:
```
merge {}           # => {}
merge { a: 0 }     # => { 'a' => 0 }
{}; merge _        # => {}
{ a: 0 }; merge _  # => { 'a' => 0 }

merge { a: 0 b: 1 } { b: 'B' c: 'C' }
 # => { 'a' => 0, 'b' => 'B', 'c' => 'C' }
merge { b: 'B' c: 'C' } { a: 0 b: 1 }
 # => { 'a' => 0, 'b' => 1, 'c' => 'C' },
```

With arrays:
```
merge [ 0 1 2 3 ] [ 'a' 'b' 'c' ]
  # => [ 'a', 'b', 'c', 3 ],

merge []            # => []
merge [ 0 1 2 ]     # => [ 0, 1, 2 ]
[]; merge _         # => []
[ 0 1 2 ]; merge _  # => [ 0, 1, 2 ]
```

It determines if it has to deal with arrays or objects by looking at its
first argument (not the incoming ret).

It fails if the arguments are not all objects or not all arrays.

If the attribute `lax:` (or `loose:`) is set to `true`, it doesn't care
about non matching arguments and merges anyway:
```
merge { a: 0 } { b: 1 } 'nada' { c: 2 } lax: true
  # => { 'a' => 0, 'b' => 1, 'c' => 2 }
merge { a: 0 } { b: 1 } { c: 2 }
  # => { 'a' => 0, 'b' => 1, 'c' => 2 }
merge { a: 0 } { b: 1 } 'nada' { c: 2 } tags: 'xxx' loose: true
  # => { 'a' => 0, 'b' => 1, 'c' => 2 }
```

`strict: false` is OK as well:
```
merge { a: 0 } { b: 1 } 'nada' { c: 2 } strict: false
  # => { 'a' => 0, 'b' => 1, 'c' => 2 }
```


## see also

[reverse](reverse.md), [length](length.md), [keys](keys.md)


* [source](https://github.com/floraison/flor/tree/master/lib/flor/pcore/merge.rb)
* [merge spec](https://github.com/floraison/flor/tree/master/spec/pcore/merge_spec.rb)

