
# on_cancel

Counterpart to the on_cancel: attribute.

```
set f.l []
sequence
  on_cancel (def msg \ push f.l "$(msg.point):$(msg.nid)")
  push f.l 0
  cancel '0_1' # cancels the containing sequence
  push f.l 1
push f.l 2
```
Ends up with `[ 0, 'cancel:0_1', 2 ]` in the field `l`.


## see also

[On](on.md), [on_error](on_error.md).


* [source](https://github.com/floraison/flor/tree/master/lib/flor/pcore/on_cancel.rb)
* [on_cancel spec](https://github.com/floraison/flor/tree/master/spec/pcore/on_cancel_spec.rb)

