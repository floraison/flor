
# language.md

Flor is mostly an interpreter. It takes as input a text, parses it into a(n abstract syntax) tree and traverses it node by node.

Here is an example tree:
```ruby
["sequence", [
  ["task", [["_att", [["_sqs", "a", 3]], 3]], 3],
  ["task", [["_att", [["_sqs", "b", 4]], 4]], 4]],
  2]
```

That's a lot of square brackets. Flor proposes a "flor" languages for generating such trees.

Here is the above tree in that flor language:
```
sequence
  task 'a'
  task 'b'
```

## indentation

Indentation is significant. In the small example above both tasks follow and are indented deeper than the sequence, so they are children of the sequence.

Warning: be consistent with the indentation of the children. In the following sequence, `task 'b'` is a child of `task 'a'`, not of `sequence`:
```
sequence
  task 'a'
   task 'b'
```

## procedures

Flor comes with a set of [predefined procedures](https://github.com/floraison/flor/tree/master/doc/procedures#procedures).

### arrays and objects

## attributes
### the _ attribute

## parentheses

## indentation again

Coming back to the subject of indentation. Sometimes, indenting everything might be pain, sometimes emphasis has to be put on certain things, while compacting some other things.

### backslash

The backslash `\` joins two lines, enforcing a parent \ child relationship.

```
  parent \ child _
      # equivalent to
  parent
    child _
      # equivalent to
  parent \
child _
      # equivalent to
  parent
\ child _
```

The `\` can be used to make one-liners around anonymous functions, like in:

```
cmap [ 1 2 3 ] \ def x \ * x 2
    # equivalent to
cmap [ 1 2 3 ]
  def x \ * x 2
    # equivalent to
cmap [ 1 2 3 ]
  def x
    * x 2
```

Note the slope in the indented version just above. The backslash symbolizes it.

### pipe or semicolon

Pipe `|` and semicolon `;` have the same effect, the bind the two nodes they stand between in a sibling relationship.

```
sequence \ a | b | c
sequence \ a ; b ; c
    # is equivalent to
sequence
  a | b | c
    # is equivalent to
sequence
\ a
| b
| c
    # is equivalent to
sequence
  a
  b
  c
```

### collection comma

Arrays and objects in JSON have their elements separated by commas. This is not necessary in flor.

```
[ 1 2 3 ]
  # is equivalent to
[ 1, 2, 3 ]
  # is equivalent to
[ ,1,,, 2, 3, ]
```

As seen above, the comma is optional.

It is useful in certain cases:
```
  task 'bob',
    context: 'customer has a leak in kitchen',
    mission: 'investigate leak'
```

The "collection" of attributes in a line also accept optional commas. The two trailing commas here bind the following lines to the initial "task" line and (imo) improve readability.

In an array or an object, the closing `[` or `{` is expected, so introducing newlines is OK.
```
  [ 1
    2 3 ]
  { a: 'a'
    b: 'b' }
```

