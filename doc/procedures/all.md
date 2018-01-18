
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

## see also

[Any?](any.md)


* [source](https://github.com/floraison/flor/tree/master/lib/flor/pcore/all.rb)

