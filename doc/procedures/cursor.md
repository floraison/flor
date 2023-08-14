
# cursor

Executes child expressions in sequence, but may be "guided".

```
cursor
  task 'alpha'
  task 'bravo' if f.amount > 2000
  task 'charly'
```

## "orders" understood by cursors

### break

Cursor understands `break`. For example, this execution will go from
"alpha" to "charly", task "bravo" will not be visited.
```
cursor
  task 'alpha'
  break _
  task 'bravo'
task 'charly'
```

### continue

Cursor also understands `continue`. It's useful to rewind a cursor:
```
cursor
  sales_team "fill in customer details"
  ops_team "attribute account number"
  continue _ if f.ops_decision == 'reject'
  create_account _
```

### move

Cursor accepts move orders, as in:
```
cursor
  do-this
  move to: 'do-that-other-thing'
  do-that _ # got skipped
  do-that-other-thing _
```


## cursor and tags

```
cursor 'main'
  # is equivalent to
cursor tag: 'main'
```

Tags on cursors are useful for "break" and "continue" (as well as "cancel"),
letting them act on other cursors.


## cursor and start: / initial: attribute

Sometimes, it is necessary to enter a cursor not at its first child, but
its second or third. Once such a cursor is entered and a `continue` is
met it will "rewind" to the first child (not the "start" child).

```
task 'create mandate'
cursor start: 'approve mandate'
  task 'amend mandate'
  task 'approve mandate'               # <-- first "cycle" will start here
  continue _ if f.outcome == 'reject'  # <-- will go to "amend mandate"
task 'activate mandate'
```

The string passed to start:/initial: is looked up (down) in the cursor
in the order: (example `cursor start: 'bravo'`)

* tag (for example `push l 'b' tag: 'bravo'`)
* string argument (for example `task 'toto' context: 'bravo'`)
* string target (for example `task 'bravo'`)
* name target (for example `bravo _`)
* att target (for example `task 'toto' bravo: 'ok'`)

## see also

[Break](break.md), [continue](break.md), [loop](loop.md).


* [source](https://github.com/floraison/flor/tree/master/lib/flor/pcore/cursor.rb)
* [cursor spec](https://github.com/floraison/flor/tree/master/spec/pcore/cursor_spec.rb)

