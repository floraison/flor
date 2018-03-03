
# on

Traps a signal by name.

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


## see also

[Trap](trap.md) and [signal](signal.md).


* [source](https://github.com/floraison/flor/tree/master/lib/flor/punit/on.rb)
* [on spec](https://github.com/floraison/flor/tree/master/spec/punit/on_spec.rb)

