
# type-of, type

returns the type of argument or the incoming f.ret.

```
type-of "hello"   # ==> 'string'
type-of 1         # ==> 'number'
type-of 1.1       # ==> 'number'
type-of [ 'a' 1 ] # ==> 'array'
type-of { a: 1 }  # ==> 'object'

type {}    # ==> 'object'
type true  # ==> 'boolean'
```

## see also

[array?](array_qmark.md), [number?](array_qmark.md), ...


* [source](https://github.com/floraison/flor/tree/master/lib/flor/pcore/type_of.rb)

