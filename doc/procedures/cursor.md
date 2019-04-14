
# cursor

Executes child expressions in sequence, but may be "guided".

```
cursor
  task 'alpha'
  task 'bravo' if f.amount > 2000
  task 'charly'
```

## break

Cursor understands `break`. For example, this execution will go from
"alpha" to "charly", task "bravo" will not be visited.
```
cursor
  task 'alpha'
  break _
  task 'bravo'
task 'charly'
```

## continue

Cursor also understands `continue`. It's useful to rewind a cursor:
```
cursor
  sales_team "fill in customer details"
  ops_team "attribute account number"
  continue _ if f.ops_decision == 'reject'
  create_account _
```

## move

Cursor accepts move orders, as in:
```
cursor
  do-this
  move to: 'do-that-other-thing'
  do-that _ # got skipped
  do-that-other-thing _
```

## see also

[Break](break.md), [continue](break.md), [loop](loop.md).


* [source](https://github.com/floraison/flor/tree/master/lib/flor/pcore/cursor.rb)
* [cursor spec](https://github.com/floraison/flor/tree/master/spec/pcore/cursor_spec.rb)

