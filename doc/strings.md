
# strings

Flor should support any UTF-8 string. String literals are expressed between quotes or double quotes.

There is no facility for multiline strings. Big literal strings could get in the way of terse process definitions.

## single quoted strings

```
'this is a single quote string.'
```

Single quoted strings do not allow for the "dollar notation". The following strings is taken literally:
```
'Responsible person: $(user.name) ($(user.age))'
```

## double quoted strings

Double quoted strings allow for the "dollar notation".

```
"Responsible person: $(user.name) ($(user.age))"
```

## the dollar notation

As seen above the dollar notation lets one insert flor code inside of double quoted strings. The result of the evaluation of this code is turned into a string an intertwined in the host string.
```
set text0 "Responsible person: $(users.0.name) ($(users.0.age))"
set text1 "Team size: $(length users)"
```

See [dollar_spec.rb](../spec/core/dollar_spec.rb).

## string concatenation

The `+` procedure can be used to concatenate strings.

```
+ "he" "lo"  # yields "hello"
  # or
"he" + "lo"
```

Adding a string to a number yields an error.
```
+ 1 "lo"  # fails...
```

If the first operand to a `+` is a string, then all subsquent operands are turned into strings and the result is the concatenation of all the strings.
```
+ '' 1 true [ 1 2 ]  # yields "1true[1, 2]"
```

## joining arrays

TODO

