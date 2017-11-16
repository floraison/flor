
# keys, values

Returns the "keys" or the "values" of an object.

```
keys { a: 'A', b: 'B' }
  # f.ret --> [ 'a', 'b' ]
values { a: 'A', b: 'B' }
  # f.ret --> [ 'A', 'B' ]
```

When used against an array, the indexes will be the numerical indexes
0 to array length - 1.

```
keys [ 1, 'to', true ]
  # f.ret -> [ 0, 1, 2 ]
values [ 1, 'to', true ]
  # f.ret -> [ 1, 'to', true ]
```

When used against something that is neither an object nor an array
it will fail.

## see also

[length](length.md)


* [source](https://github.com/floraison/flor/tree/master/lib/flor/pcore/keys.rb)
* [keys spec](https://github.com/floraison/flor/tree/master/spec/pcore/keys_spec.rb)

