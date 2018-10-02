
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

