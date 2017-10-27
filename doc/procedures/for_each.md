
# for-each

Calls a function for each element in the argument collection.

When the "for-each" ends, `f.ret` is pointing back to the argument
collection.

```
set l []
for-each [ 0 1 2 3 4 5 6 7 ]
  def x
    pushr l (2 * x) if x % 2 == 0
```
the var `l` will yield `[ 0, 4, 8, 12 ]` after the `for-each`
the field `ret` will yield `[ 0, 1, 2, 3, 4, 5, 6, 7 ]`.


* [source](https://github.com/floraison/flor/tree/master/lib/flor/pcore/for_each.rb)

