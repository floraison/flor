
# def, fun, define

Defines a function.

In its `define` flavour, will take a function body and assign it to
variable.
```
define sum a, b # make variable 'sum' hold the function
  +
    a
    b
  # yields the function, like `fun` and `def` do

sum 1 2
  # will yield 3
```

In the `fun` and `def` flavours, the function is unnamed, it's thus not
bound in a local variable.
```
map [ 1, 2, 3 ]
  def x
    + x 3
# yields [ 4, 5, 6 ]
```

