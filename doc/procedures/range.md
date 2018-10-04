
# range

Generates ranges of integers.

```
# range {end}
# range {start} {end}
# range {start} {end} {step}
range 0         #--> []
range 4         #--> [ 0, 1, 2, 3 ]
range 4 7       #--> [ 4, 5, 6 ]
range 4 14 2    #--> [ 4, 6, 8, 10, 12 ]
range (-4)      #--> [ 0, -1, -2, -3 ]
range 9 1 (-2)  #--> [ 9, 7, 5, 3 ] ]
```

```
range from: 9 to: 1 by: -2
  # or
range start: 9 end: 1 step: -2
  #
  # are also accepted
```


* [source](https://github.com/floraison/flor/tree/master/lib/flor/pcore/range.rb)
* [range spec](https://github.com/floraison/flor/tree/master/spec/pcore/range_spec.rb)

