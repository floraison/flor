
# move

Moves a cursor to a given position, a kind of local goto.

```
cursor
  do-this _
  move to: 'do-that-other-thing'
  do-that _ # gets skipped
  do-that-other-thing _
```


* [source](https://github.com/floraison/flor/tree/master/lib/flor/pcore/move.rb)
* [move spec](https://github.com/floraison/flor/tree/master/spec/pcore/move_spec.rb)

