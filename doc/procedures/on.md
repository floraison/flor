
# on

Traps a signal by name

Turns
```
on 'approve'
  task 'bob' mission: 'gather signatures'
```
into
```
trap point: 'signal', name: 'approve'
  set sig 'signal'
  def msg
    task 'bob' mission: 'gather signatures'
```


* [source](https://github.com/floraison/flor/tree/master/lib/flor/punit/on.rb)
* [on spec](https://github.com/floraison/flor/tree/master/spec/punit/on_spec.rb)

