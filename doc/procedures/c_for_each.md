
# c-for-each

Concurrent "for-each", launches a concurrent branch for each elt or entry
of the incoming collection.

```
c-for-each [ 'alice' 'bob' 'charly' ]
  def user \ task user 'contact customer group'
    #
    # is thus equivlent to
    #
task 'alice' 'contact customer group'
task 'bob' 'contact customer group'
task 'charly' 'contact customer group'
```

By default, the incoming `f.ret` collection is used:
```
[ 'alice' 'bob' 'charly' ]
c-for-each
  def user \ task user 'contact customer group'
```

## see also

[For-each](for_each.md) and [cmap](cmap.md).


* [source](https://github.com/floraison/flor/tree/master/lib/flor/punit/c_for_each.rb)
