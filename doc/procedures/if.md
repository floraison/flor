
# if, unless, ife, unlesse

The classical "if" (and its "unless" sidekick)

```
if
  > f.age 3
  set f.designation 'child' # then
  set f.designation 'baby' # else

if (f.age > 3)
  sequence # then
    set f.designation 'child'
  sequence # else
    set f.designation 'baby'
    order_baby_food _
```

Warning, the direct children are relevant. In the following snip,
`order_child_seat` is considered the "else" part of the `if`
```
if (f.age > 3)
  set f.designation 'child'
  order_child_seat _
```

## postfix `if` and `unless`

The flor parser will automatically turn
```
task 'bob' if a > b
```
into the syntax tree that would result from
```
if
  a > b
  task 'bob'
```

## else-if

Currently, if an "else if" is needed, it's better to use [cond](cond.md).


## see also

[Cond](cond.md), [case](case.md), [match](match.md).


* [source](https://github.com/floraison/flor/tree/master/lib/flor/pcore/if.rb)
* [if spec](https://github.com/floraison/flor/tree/master/spec/pcore/if_spec.rb)

