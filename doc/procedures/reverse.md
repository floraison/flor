
# reverse

Reverses an array or a string.

```
reverse [ 0, 2, 4 ]
  # --> sets f.ret to [ 4, 2, 0 ]
reverse "melimelo"
  # --> sets f.ret to "olemilem"
```

Reverses f.ret if there are no arguments
```
[ 5, 6, 4 ]   # sets f.ret to [ 5, 6, 4 ]
reverse _     # sets f.ret to [ 4, 6, 5 ]
```

Will fail if it finds nothing reversable.


* [source](https://github.com/floraison/flor/tree/master/lib/flor/pcore/reverse.rb)
* [reverse spec](https://github.com/floraison/flor/tree/master/spec/pcore/reverse_spec.rb)

