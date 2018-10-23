
# cond

Evaluates all its condition children until one evaluates to true
(or it's an else), then executes the corresponding clause child.

```
set a 4
cond
  a < 4              # condition 0
  "less than four"   # clause 0
  a < 7              # condition 1
  "less than seven"  # ...
  a < 10
  "less than ten"
```
will yield "less than seven".

```
set a 11
cond
  a < 4 ; "less than four"
  a < 7 ; "less than seven"
  else ; "ten or bigger"
```
will yield "ten or bigger".

The semicolon is used to place condition and clause on the same line.
A pipe can be used instead of a semicolon.
```
set a 11
cond
  a < 4 | "less than four"
  a < 7 | "less than seven"
  else | "ten or bigger"
```

Please note that, as for [if](if.md), composite consequences have to be
"packaged":
```
cond
  a < 4
    sequence
      do_this
      do_that
  a < 7
    concurrence
      do_this
      do_that
  else
    sequence
      do_this 'default'
      do_that 'default'
```

## see also

[If](if.md), [match](match.md), [case](case.md).


* [source](https://github.com/floraison/flor/tree/master/lib/flor/pcore/cond.rb)
* [cond spec](https://github.com/floraison/flor/tree/master/spec/pcore/cond_spec.rb)

