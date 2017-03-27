
# nodes.md

The flor interpreter builds executions as trees.

For example, executing this piece of flor
```
concurrence
  task 'alpha'
  task 'bravo'
```
will result in the following tree (right after alpha and bravo got tasked)
```
  "0" concurrence
   ├── "0_0" task 'alpha'
   └── "0_1" task 'bravo'
```

## execution

An execution is a JSON object with at least two entries.

* exid: the execution identifier, something like "test-u0-20170325.0458.muriyushabi"
* nodes: an object containing nodes keyed with their nid.

Our above example could thus be represented as
```js
{
  exid: "test-u0-20170325.0458.muriyushabi",
  nodes: {
    "0": { /* node 0 */ },
    "0_0": { parent: "0", /* node */ },
    "0_1": { parent: "0", /* node */ },
  }
}
```

## a procedure and its node

A procedure (for example "sequence", "concurrence" or "task") is backed up by a node.

The procedure implementation decides how the node should behave upon receiving messages.

A "concurrence" procedure right after having its node created by an "execute" message will emit one "execute" message for each of the children in its tree.

A "sequence" procedure will only emit one "execute" message at a time. Upon receiving a "receive" message, the sequence will emit an "execute" message for the next child. If the "receive" was from the last child, the sequence procedure will reply to its parent, by sending a "receive" message to it.

## building up and tearing down

"execute" [messages](messages.md) add nodes to the execution, while "receive" messages tend to remove nodes from the execution.

"execute" messages thus go from the root of the execution to its leaves.

"receive" messages go from the leaves towards the root.

"cancel" messages go from the root to the leaves as well.

### "execute"
### "receive"
### "cancel"

## rules

* an "execute" message creates a node, the created node id (nid) is added to the cnodes of the node that emitted the execute message

* a "cancel" message closes the target node (its status becomes "closed")
* if there are no child nodes, a "cancel" message will trigger a reply (with cause: "cancel") to the parent node
* if there are child nodes, a "cancel" message will emit a "cancel" message towards each child node

* ...

### basic behaviour

"execute" creates a node and calls the `#execute` method of the corresponding procedure. The nid of the new node is added to the 'cnodes' list of the node that emitted the "execute" message.

"receive" removes...

TODO continue me!

