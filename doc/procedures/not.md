
# not

`not` negates its last child (or its last unkeyed attribute)

```
not _      # --> true
not true   # --> false
not false  # --> true
not 0      # --> false
not 1      # --> false
```

```
not
  true
  false  # --> true
```


* [source](https://github.com/floraison/flor/tree/master/lib/flor/pcore/not.rb)
* [not spec](https://github.com/floraison/flor/tree/master/spec/pcore/not_spec.rb)

