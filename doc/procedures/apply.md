
# apply

Applies a function.

```
sequence
  define sum a b
    +
      a
      b
  apply sum 1 2
```

It is usually used implicitely, as in
```
sequence
  define sum a b
    +
      a
      b
  sum 1 2
```
where flor figures out by itself it has to use this "apply" procedure
to call the function.


* [source](https://github.com/floraison/flor/tree/master/lib/flor/pcore/apply.rb)
* [apply spec](https://github.com/floraison/flor/tree/master/spec/pcore/apply_spec.rb)

