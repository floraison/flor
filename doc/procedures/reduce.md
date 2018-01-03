
# reduce

Reduce takes a collection and a function. It reduces the collection
to a single result thanks to the function.

```
reduce [ '0', 1, 'b', 3 ]
  def result element
    result + element
# --> "01b3"
```

An initial value is accepted (generally after the collection)

```
reduce [ 0, 1, 2, 3, 4 ] 10
  def result i \ result + i
# --> 20
```

Passing a proc is OK too, but, in the case of a mathematical expression
prefixing it with `v.` prevents premature rewriting...

```
reduce [ 0, 1, 2, 3, 4 ] 10 v.+
# --> 20
```

## see also

[Inject](inject.md).


* [source](https://github.com/floraison/flor/tree/master/lib/flor/pcore/reduce.rb)
* [reduce spec](https://github.com/floraison/flor/tree/master/spec/pcore/reduce_spec.rb)

