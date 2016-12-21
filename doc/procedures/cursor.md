
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


* [source](https://github.com/floraison/flor/tree/master/lib/flor/pcore/cursor.rb)
* [cursor spec](https://github.com/floraison/flor/tree/master/spec/pcore/cursor_spec.rb)

