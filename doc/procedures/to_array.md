
# to-array

Turns an argument into an array.

```
to-array [ 0 1 2 ]
  # --> [ 0 1 2 ]  # (left intact)

to-array 123
  # --> [ 123 ]

to-array { a: 'A', b: 'B' }
  # --> [ [ 'a', 'A' ], [ 'b', 'B' ] ]
```

## see also

to-object


* [source](https://github.com/floraison/flor/tree/master/lib/flor/pcore/to_array.rb)

