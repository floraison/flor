
# until, while

Loops until or while a condiation evaluates to true.

```
set i 0
until i == 7
  task 'bob' "verify counter ($(i))"
  set i (i + 1)
```

```
set i 0
while i < 7
  task 'bob' "verify counter ($(i))"
  set i (i + 1)
```

`until` and `while` understand `break` and `continue`, like `cursor` and
`loop` do.

```
until
  false
  push f.l 0
  set outer-break break # alias local break to "outer-break"
  until false
    push f.l 'a'
    outer-break 'x'
```

## see also

[Break](break.md), [continue](break.md), [cursor](cursor.md), [loop](loop.md).


* [source](https://github.com/floraison/flor/tree/master/lib/flor/pcore/until.rb)
* [until spec](https://github.com/floraison/flor/tree/master/spec/pcore/until_spec.rb)

