
# matchr, match?, pmatch

Matches a string against a regular expression.

`matchr s r` will return an array of matching strings in `s` from regular
expression `r`.

`match? s r` will return true if string `s` matches regular expression `r`.
It returns false else.

`pmatch s r` will return false it it doesn't match, it will return the
string matched else. If there is a capture group (parentheses) in the
pattern, it will return its content instead of the whole match.

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

When there is a single argument, `matchr` and `match?` will try
to take the string out of `$(f.ret)`.
```
"blue moon"
match? (/blue/)
  # => true

"blue moon"
match? 'blue'
  # => true

/blue/
match? 'blue moon'
  # => true

'blue'
match? (/black/)
  # => false
```

```
# pmatch
pmatch 'string', /^str/                     # ==> 'str'
pmatch 'string', /^str(.+)$/                # ==> 'ing'
pmatch 'string', /^str(?:.+)$/              # ==> 'string'
pmatch 'strogonoff', /^str(?:.{0,3})(.*)$/  # ==> 'noff'
pmatch 'sutoringu', /^str/                  # ==> false
```


* [source](https://github.com/floraison/flor/tree/master/lib/flor/pcore/matchr.rb)
* [matchr spec](https://github.com/floraison/flor/tree/master/spec/pcore/matchr_spec.rb)

