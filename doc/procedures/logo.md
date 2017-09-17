
# and, or

When `and` evaluates the children and returns false as soon
as one of returns a falsy value. Returns true else.
When `or` evaluates the children and returns true as soon
as one of them returns a trueish value. Returns false else.

```
and
  false
  true
    # => evalutes to false
```

```
and (check_this _) (check_that _)
```

Gives priority to `and` over `or`.


* [source](https://github.com/floraison/flor/tree/master/lib/flor/pcore/logo.rb)

