
# flatten

Flattens the given array

```
flatten [ 1, [ 2, [ 3 ], 4 ] ]     # ==> [ 1, 2, 3, 4 ]
flatten [ 1, [ 2, [ 3 ], 4 ] ], 1  # ==> [ 1, 2, [ 3 ], 4 ]

[ 1, [ 2, [ 3 ], 4 ] ]
flatten 1  # ==> [ 1, 2, [ 3 ], 4 ]

[ 1, [ 2, [ 3 ], 4 ] ]
flatten _  # ==> [ 1, 2, 3, 4 ]
```


* [source](https://github.com/floraison/flor/tree/master/lib/flor/pcore/flatten.rb)
* [flatten spec](https://github.com/floraison/flor/tree/master/spec/pcore/flatten_spec.rb)

