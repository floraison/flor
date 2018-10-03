
# downcase, lowercase, lowcase, upcase, uppercase, capitalize

Functions that deal with strings

"downcase", "lowercase", "lowcase",
"upcase", "uppercase",
"capitalize"

```
downcase 'HELLO'           # => 'hello'
'HELLO'; downcase _        # => 'hello'
'HELLO'; downcase 'WORLD'  # => 'world'
# ...
```

## objects and arrays

Please note:

```
[ "A" "BC" "D" ]; downcase _    # => [ 'a' 'bc' 'd' ]
{ a: "A" b: "BC" }; downcase _  # => { a: 'a', b: 'bc' }
```

## see also

[length](length.md), [reverse](reverse.md)


* [source](https://github.com/floraison/flor/tree/master/lib/flor/pcore/strings.rb)

