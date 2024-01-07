
# if, unless, ife, unlesse, _if, _unless

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

## improving readability with else and then

"then" and "else" can be aliased to "sequence" and be used within if to
make the flow definition easier to read, and especially less confusing.

```
# at the top of the workflow definition
# alias "then" and "else" to "sequence"

set then sequence
set else sequence

# ...

if (f.age > 3)
  then
    set f.designation 'child'
  else
    set f.designation 'baby'
    order_baby_food _
```

## see also

[Cond](cond.md), [case](case.md), [match](match.md).


* [source](https://github.com/floraison/flor/tree/master/lib/flor/pcore/if.rb)
* [if spec](https://github.com/floraison/flor/tree/master/spec/pcore/if_spec.rb)

