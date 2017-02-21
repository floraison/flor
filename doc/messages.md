
# messages.md

The job of the executors is to process messages. Each message has a "point", the most common is "execute", it creates a new node. Other messages impact those living nodes.

## keys common to all messages (or most of them)

### "point"
### "exid"
### "nid"
### "payload"
### "vars"
### "m"
### "sm"

## messages by point

### "execute"

As said above an "execute" message creates a new node (unless the "tree" it holds is broken at its root).

```js
{
  point: "execute",
  exid: "xxx", // execution id
  nid: "xxx", // node id
  tree: [ "task", { "_0": "stamp" }, [] ],
  payload: { color: "blue" }
}
```

### "receive"
### "failed"
### "task"
### "return"
### "cancel"
### "terminated"
### "signal"

