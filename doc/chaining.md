
# chaining

Some procedures will work with the incoming `f.ret` if there is no fitting argument provided to them directly.

```
[ 'a' 'b' 'c' 'd' ]
  map
    def v
      + v v      # f.ret is now [ 'aa' 'bb' 'cc' 'dd' ]
  collect
    + elt elt    # f.ret is now [ 'aaaa' 'bbbb' 'cccc' 'dddd' ]
```
or
```
[ 'a' 'b' 'c' 'd' ]
  map (def v \ + v v)
  collect \ + elt elt
```

Equivalent to Ruby's:
```ruby
%w[ a b c d ]
  .map { |v| v + v }
  .collect { |v| v + v }
```

Procedures able to "chain":

* [all?](procedures/all.md)
* [any?](procedures/any.md)
* [empty?](procedures/empty.md)
* [each](procedures/each.md) and [for-each](procedures/for_each.md)
* [filter](procedures/filter.md) and [select](procedures/select.md)
* [find](procedures/find.md) and [detect](procedures/detect.md)
* [flatten](procedures/flatten.md)
* [includes?](procedures/includes.md)
* [keys](procedures/keys.md) and [values](procedures/keys.md)
* [length](procedures/length.md)
* [map](procedures/map.md) and [collect](procedures/select.md)
* [merge](procedures/merge.md)
* [c_map](procedures/c_map.md) and [c_collect](procedures/c_collect.md)
* [reduce](procedures/reduce.md) and [inject](procedures/inject.md)
* [reverse](procedures/reverse.md)
* [slice](procedures/slice.md) and [index](procedures/slice.md)
* [downcase, lowercase, lowcase, upcase, uppercase, capitalize](procedures/strings.md)

