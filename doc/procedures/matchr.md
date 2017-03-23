
# matchr, match?

Matches a string against a regular expression.

`matchr s r` will return an array of matching strings in `s` from regular
expression `r`.

`match? s r` will return true if string `s` matches regular expression `r`.
It returns false else.

```
matchr "alpha", /bravo/
  # yields an empty array []

match? "alpha", /bravo/  # => false
match? "alpha", /alp/    # => true
```

The second argument to `match?` and `matchr` is turned into a
regular expression.
```
match? "alpha", 'alp'    # => true
```


* [source](https://github.com/floraison/flor/tree/master/lib/flor/pcore/matchr.rb)
* [matchr spec](https://github.com/floraison/flor/tree/master/spec/pcore/matchr_spec.rb)

