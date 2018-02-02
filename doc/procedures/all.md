
# all?

Returns true if all the elements in a collection return true
for the given function.

```
all? [ 1, 2, 3 ]
  def elt \ elt > 0
    #
    # yields true

all? [ 1, 2, 3 ]
  def elt \ elt > 2
    #
    # yields false
```

```
all? { a: 'A', b: 'B' }
  def key, val \ val == 'A' or val == 'B'
    #
    # yields true
```

### without a function

For an array, yields true if all the elements are "trueish" (not nil,
not false).

```
all? []                            # yields true
all? [ 1 2 3 ]                     # yields true
all? [ 1 false 3 ]                 # yields false
```

For an object, yields true if all the values are trueish.

```
all? {}                            # yields true
all? { a: 'A', b: 'B', c: 'C' }    # yields true
all? { a: 'A', f: false, c: 'C' }  # yields false
```

## see also

[Any?](any.md)


* [source](https://github.com/floraison/flor/tree/master/lib/flor/pcore/all.rb)

