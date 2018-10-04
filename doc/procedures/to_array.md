
# to-array, to-object

Turns the argument into an array or an object.

```
to-array [ 0 1 2 ]
  # --> [ 0 1 2 ]  # (left intact)

to-array 123
  # --> [ 123 ]

to-array { a: 'A', b: 'B' }
  # --> [ [ 'a', 'A' ], [ 'b', 'B' ] ]
```

and

```
to-object [ 'a' 'A' 'b' 'B' 'c' 'C' ]
  # --> { 'a': 'A', b: 'B', c: 'C' }
```


* [source](https://github.com/floraison/flor/tree/master/lib/flor/pcore/to_array.rb)

