
# sequence, _apply, begin

Executes child expressions in sequence.

```
sequence
  task 'alpha'
  task 'bravo' if f.amount > 2000
  task 'charly'
```


* [source](https://github.com/floraison/flor/tree/master/lib/flor/pcore/sequence.rb)
* [sequence spec](https://github.com/floraison/flor/tree/master/spec/pcore/sequence_spec.rb)

