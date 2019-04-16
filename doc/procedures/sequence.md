
# sequence, begin

Executes child expressions in sequence.

```
sequence
  task 'alpha'
  task 'bravo' if f.amount > 2000
  task 'charly'
```

Giving a string as attribute result to "sequence" lets it interpret
that string as a tag name, as in:
```
sequence 'phase one'
  alice 'gather customer requirements'
  bob 'establish offer'
sequence 'phase two'
  alice 'present offer to customer'
  bob 'sign contract'
```
It is equivalent to:
```
sequence tag: 'phase one'
  alice 'gather customer requirements'
  bob 'establish offer'
sequence tag: 'phase two'
  alice 'present offer to customer'
  bob 'sign contract'
```
Learn more about [tags](../tags.md).

Please note that it sets only 1 tag, and if there are already tags
sets (`sequence tags: [ 'a' 'b' ] "this won't become a tag"`), it won't set
further tags.

## see also

[Concurrence](concurrence.md), [loop](loop.md)


* [source](https://github.com/floraison/flor/tree/master/lib/flor/pcore/sequence.rb)
* [sequence spec](https://github.com/floraison/flor/tree/master/spec/pcore/sequence_spec.rb)

