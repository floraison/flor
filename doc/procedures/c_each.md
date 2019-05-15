
# ceach, c-each

Concurrent "each".

```
ceach [ alice bob charly ]
  task elt "prepare monthly report"
```
which is equivalent to
```
concurrence
  task 'alice' "prepare monthly report"
  task 'bob' "prepare monthly report"
  task 'charly' "prepare monthly report"
```

## see also

[For-each](for_each.md), c_map, and c_each.


* [source](https://github.com/floraison/flor/tree/master/lib/flor/punit/c_each.rb)
* [c-each spec](https://github.com/floraison/flor/tree/master/spec/punit/c_each_spec.rb)

