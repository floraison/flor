
# on_receive

Binds a function to the parent node, the function will be called each time
the parent node "receives".

```
set l []
sequence
  on_receive (def msg \ push l 'a')
  push l 0
  push l 1
  push l 2
```
will result in the variable `l` holding `[ 0, 'a', 1, 'a', 2, 'a' ]`.

```
set l []
sequence
  push l 0
  on_receive (def msg \ push l 'a')
  push l 1
  push l 2
```
will result in the variable `l` holding `[ 0, 1, 'a', 2, 'a' ]`.

It's meant to play well with a cursor:
```
set l []
cursor
  on_receive (def \ break _ if l[-1] == 1)
  push l 0
  push l 1
  push l 2
push l 'z'
```
will result in the variable `l` holding `[ 0, 1, 'z' ]`.


## on_receive and on receive

A "lighter" notation is available (it's translated automatically to a
`on_receive`):
```
set l []
cursor
  on receive
    push l $msg.from
    break _ if l.-1 == 1
  push l 0
  push l 1
  push l 2
```

Please note the `$msg` variable made available to the `on receive` block.


## concurrence and on_receive

Please not that `concurrence` has its own `on_receive` with a slightly
different behaviour.


* [source](https://github.com/floraison/flor/tree/master/lib/flor/pcore/on_receive.rb)
* [on_receive spec](https://github.com/floraison/flor/tree/master/spec/pcore/on_receive_spec.rb)

