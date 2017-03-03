
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

