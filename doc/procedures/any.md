
# any?

Returns `true` if at least one of the member of a collection returns
something trueish for the given function. Returns `false` else.

```
any? [ 1, 2, 3 ]
  def elt
    (elt % 2) == 0
# yields `true` thanks to element `2`
```

```
any? { a: 'A', b: 'B', c: 'C' }
  def key, val \ val == 'B'
# yields `true` thanks to entry { b: 'B' }
```

## without a function

It's OK to use "any?" without a function, it'll simply return
false if the collection is empty, true else.

```
any? []          # yields false
any? [ 1 ]       # yields true
any? {}          # yields false
any? { a: 'A' }  # yields true
```


## see also

[Find](find.md), [all?](all.md).


* [source](https://github.com/floraison/flor/tree/master/lib/flor/pcore/any.rb)

