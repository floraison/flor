
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

## see also

[If](if.md), [match](match.md).


* [source](https://github.com/floraison/flor/tree/master/lib/flor/pcore/cond.rb)
* [cond spec](https://github.com/floraison/flor/tree/master/spec/pcore/cond_spec.rb)

