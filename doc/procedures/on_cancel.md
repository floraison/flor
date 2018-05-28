
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

## on and on_cancel

"on_cancel" is made to allow for `on cancel`, so that:
```
sequence
  on cancel
    push f.l msg # a block with a `msg` variable
  # ...
```
gets turned into:
```
sequence
  on_cancel
    def msg # a anonymous function definition with a `msg` argument
      push f.l msg
  # ...
```


## see also

[On](on.md), [on_error](on_error.md).


* [source](https://github.com/floraison/flor/tree/master/lib/flor/pcore/on_cancel.rb)
* [on_cancel spec](https://github.com/floraison/flor/tree/master/spec/pcore/on_cancel_spec.rb)

