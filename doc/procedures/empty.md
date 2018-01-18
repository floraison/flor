
# empty?

Returns true if the given collection is empty.

Returns true of the given argument is null, returns false for any
other non-collection argument.

```
empty? []           # --> true
empty? {}           # --> true
empty? ''           # --> true
empty? null         # --> true

empty? [ 1, 2, 3 ]  # --> false
empty? { a: 'A' }   # --> false
empty? 0            # --> false
empty? 'aaa'        # --> false
```

## see also

[any?](any.md)


* [source](https://github.com/floraison/flor/tree/master/lib/flor/pcore/empty.rb)

