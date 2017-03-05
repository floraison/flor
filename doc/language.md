
# language.md

Flor is mostly an interpreter. It takes as input a tree and traverses it node by node.

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
## attributes

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
### collection comma

