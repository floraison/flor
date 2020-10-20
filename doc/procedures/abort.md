
# abort, kabort

Cancels the current execution.

Cancels all the root nodes at once. Is usually the equivalent of
`cancel '0'` but sometimes the root nodes are gone...

"kabort" is like "abort" but the cancel flavour is 'kill', so that
cancel handlers are ignored.

```
# ...
cursor
  task 'prepare mandate'
  abort _ if f.outcome == 'reject'
  task 'sign mandate'
# ...
```

## see also

[Cancel](cancel.md), [kill](cancel.md)


* [source](https://github.com/floraison/flor/tree/master/lib/flor/punit/abort.rb)
* [abort spec](https://github.com/floraison/flor/tree/master/spec/punit/abort_spec.rb)

