
# slice, index

"slice" takes an array or a string and returns a slice of it (a new
array or a new string.

"index" takes an array or a string and returns the element (character)
at the given index.

## slice

```
set a [ 'alpha' 'bravo' 'charly' ]

slice a 1 -1            # sets [ 'bravo', 'charly' ] into the field 'ret'
slice a from: 1 to: -1  # same as above

a
slice 1 -1  # sets [ 'bravo', 'charly' ] into the field 'ret'
slice 1 -1  # sets [ 'charly' ] into the field 'ret'

a
slice 1 count: 2  # sets [ 'bravo', 'charly' ] into the field 'ret'
```

## index

```
set a [ 'alpha' 'bravo' 'charly' ]

index a (-2)    # sets 'bravo' into the field 'ret'
index a at: -2  # sets 'bravo' into the field 'ret'
```


* [source](https://github.com/floraison/flor/tree/master/lib/flor/pcore/slice.rb)
* [slice spec](https://github.com/floraison/flor/tree/master/spec/pcore/slice_spec.rb)

