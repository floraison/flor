
# on_timeout

Counterpart to the on_timeout: attribute.

Sets the on_timeout "attribute" of the parent procedure.

```
set l []
sequence timeout: '1s'
  push l 0
  on_timeout (def msg \ push l "$(msg.point):$(msg.nid)")
  stall _
  push l 2
push l 3
```
Ends up with `[ 0, 'cancel:0_1', 3 ]` in the variable `l`. The on_timeout
is set on the "sequence".

## see also

[On](on.md), [on_error](on_error.md), [on_cancel](on_cancel.md).


* [source](https://github.com/floraison/flor/tree/master/lib/flor/punit/on_timeout.rb)
* [on_timeout spec](https://github.com/floraison/flor/tree/master/spec/punit/on_timeout_spec.rb)

