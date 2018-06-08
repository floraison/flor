
# on

Catches signals or errors.

## signals

Turns
```
on 'approve'
  task 'bob' mission: 'gather signatures'
```
into
```
trap point: 'signal', name: 'approve'
  def msg
    task 'bob' mission: 'gather signatures'
```

It's OK trapping multiple signal names:
```
on [ /^bl/ 'red' 'white' ]
  task 'bob' mission: "order can of $(sig) paint"
```

## error

"on" understands `on error` with a block. It in facts turns:
```
sequence
  on error
    push f.l err.msg # a block with an `err` variable
  # ...
```
into:
```
sequence
  on_error
    def err # a anonymous function definition with an `err` argument
      push f.l err.msg
  # ...
```

Please note that "error" in `on error` is not quoted, nor double quoted.
If it were, it would trap the signal named "error".


## cancel

"on" understands `on cancel` with a block. It in facts turns:
```
sequence
  on cancel
    push f.l msg # a block with a `msg` variable
  # ...
```
into:
```
sequence
  on_cancel
    def msg # a anonymous function definition with a `msg` argument
      push f.l msg
  # ...
```

Please note that "cancel" in `on cancel` is not quoted, nor double quoted.
If it were, it would trap the signal named "cancel".


## timeout

`on timeout` turns:
```
sequence timeout: '1w'
  on timeout
    push f.l msg # a block with a `msg` variable
  # ...
```
into:
```
sequence timeout: '1w'
  on_timeout
    def msg # a anonymous function definition with a `msg` argument
      push f.l msg
  # ...
```

Please note that "timeout" in `on timeout` is not quoted, nor double quoted.
If it were, it would trap the signal named "timeout".


## see also

[Trap](trap.md) and [signal](signal.md).


* [source](https://github.com/floraison/flor/tree/master/lib/flor/pcore/on.rb)
* [on spec](https://github.com/floraison/flor/tree/master/spec/pcore/on_spec.rb)

