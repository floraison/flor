
# downcase, lowercase, lowcase, upcase, uppercase, capitalize, snakecase, snake_case, camelcase, camelCase

"downcase", "upcase", "capitalize", etc.

"downcase", "lowercase", "lowcase",
"upcase", "uppercase",
"capitalize",
"snakecase", "snake_case"

```
downcase 'HELLO'           # => 'hello'
'HELLO'; downcase _        # => 'hello'
'HELLO'; downcase 'WORLD'  # => 'world'
# ...
downcase 'WORLD'            # => 'world'
downcase 'WORLD' cap: true  # => 'World'
# ...
capitalize 'hello world'  # => 'Hello World'
```

The `cap:` attribute, when set to something trueish, will make sure the
resulting string(s) first char is capitalized. Not that "capitalize" itself
will capitalize all the words (unlike Ruby's `String#capitalize`).

## objects and arrays

Please note:

```
[ "A" "BC" "D" ]; downcase _    # => [ 'a' 'bc' 'd' ]
{ a: "A" b: "BC" }; downcase _  # => { a: 'a', b: 'bc' }
```

## see also

[length](length.md), [reverse](reverse.md)


* [source](https://github.com/floraison/flor/tree/master/lib/flor/pcore/strings.rb)

