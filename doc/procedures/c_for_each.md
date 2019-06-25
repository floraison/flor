
# c-for-each

Concurrent "for-each", launches a concurrent branch for each elt or entry
of the incoming collection.

```
c-for-each [ 'alice' 'bob' 'charly' ]
  def user \ task user 'contact customer group'
    #
    # is thus equivalent to
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

[For-each](for_each.md), [c-map](c_map.md), and [c-each](c_each.md).


* [source](https://github.com/floraison/flor/tree/master/lib/flor/punit/c_for_each.rb)
* [c-for-each spec](https://github.com/floraison/flor/tree/master/spec/punit/c_for_each_spec.rb)

