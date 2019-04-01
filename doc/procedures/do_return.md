
# do-return

Takes a set of arguments and returns a function
that will return those arguments again.

```
set a
  do-return 1
a _
```
will set 1 in the payload `ret`.

It might be useful in cases like:
```
sequence on_error: (do-return 1)
  do-this-failure-prone-thing _
```

## see also

return


* [source](https://github.com/floraison/flor/tree/master/lib/flor/pcore/do_return.rb)
* [do-return spec](https://github.com/floraison/flor/tree/master/spec/pcore/do_return_spec.rb)

