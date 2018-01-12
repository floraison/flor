
# _skip

Skips x messages, mostly used for testing flor.

```
concurrence
  sequence
    set f.i 0
    while tag: 'xx'
      true
      set f.i (+ f.i 1)
  sequence
    _skip 7 # after 7 messages will go on
    break ref: 'xx'
```

## see also

[Stall](stall.md).


* [source](https://github.com/floraison/flor/tree/master/lib/flor/pcore/_skip.rb)
* [_skip spec](https://github.com/floraison/flor/tree/master/spec/pcore/_skip_spec.rb)

