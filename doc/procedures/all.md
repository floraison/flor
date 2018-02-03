
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

## iterating and functions

Iterating functions accept 0 to 3 arguments when iterating over an
array and 0 to 4 arguments when iterating over an object.

Those arguments are `[ value, index, length ]` for arrays.
They are `[ key, value, index, length ]` for objects.

The corresponding `key`, `val`, `idx` and `len` variables are also
set in the closure for the function call.

## see also

[Any?](any.md)


* [source](https://github.com/floraison/flor/tree/master/lib/flor/pcore/all.rb)

