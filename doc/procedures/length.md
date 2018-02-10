
# length, size

Returns the length of its last collection argument or
the length of the incoming f.ret

```
length [ 0 1 2 3 ]
  # f.ret ==> 4

{ a: 'A', b: 'B', c: 'C' }
length _
  # f.ret ==> 3
```

It will fail unless "length" receives a (non-attribute) argument
that has a length.

Has the "size" alias.


* [source](https://github.com/floraison/flor/tree/master/lib/flor/pcore/length.rb)
* [length spec](https://github.com/floraison/flor/tree/master/spec/pcore/length_spec.rb)

