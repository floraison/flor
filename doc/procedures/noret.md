
# noret

Executes its children, but doesn't alter the received f.ret

```
sequence
  123
  noret
    456
  # f.ret is "back" to 123 at this point
```


* [source](https://github.com/floraison/flor/tree/master/lib/flor/pcore/noret.rb)
* [noret spec](https://github.com/floraison/flor/tree/master/spec/pcore/noret_spec.rb)

