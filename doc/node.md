
# node.md

The node is more the data, while the wrapping procedure is more about behaviour. There is a `Node` class that the `Procedure` class extends. The node class holds a node JSON document and methods to read and update it. The "concurrence", "task" and other procedure behaviours are found in the `Procedure` class and its child classes `Concurrence`, `Task`, etc.

## the node itself

A node is a JSON document with a least those entries:

* nid: the "node id"
* parent: may be null, contains the nid of the parent node
* cnodes: may be null (thus considered as an empty array), an array of the nids of the child nodes
* status: an array of hashes

## procedure

A procedure wraps a node and regulates the behaviour of the node with regard to its parent node (if any) and its child nodes (if any).

The 3 main methods in a procedure are `#execute`, `#receive` and `#cancel`. The `Procedure` class provides three "gate" implementations: `#do_execute`, `#do_receive` and `#do_cancel`. Those `#do_` methods contain lower-level details implementations, while the non-do methods focus on leaf behaviour.

The simplest procedure is the "sequence", with the following, default, behaviour:

## on execute

Node gets added to the "nodes" entry of the execution.

If the node has a parent, the node id gets added to the "cnodes" entry of the parent node.

## on receive

(the node emitting the 'receive' message is removed unless it is flanking, `point: receive, flavour: flanking`)

The last element of nid of the incoming message is used to determine if the next child has to be applied. If there is no next child, the node replies to its parent node by sending it a "receive" message.

If there is no parent, no "receive" message is emitted, but a "ceased" or a "terminated" message is emitted. "ceased" is emitted if the emitting node is different from "0", thus "terminated" is only emitted by the root "0" node.

### when closed (receive from child)

When the node is in the status "closed" and it gets a "receive" message from a node in its "cnodes" list, it will react by emitting a "receive" message towards its parent node.

If there is a "on_receive_last" entry set in the node, instead of replying to its parent, the node will emit the message kept in the "on_receive_last" entry. This mechanism is used for on_error and re_apply behaviours. In case of on_error, when the child has replied, the on_error routine gets triggered. In case of re_apply, when the child has replied, the replacement routine gets triggered.

### when closed

When the node is in the status "closed" and it gets a "receive" message from a non-child node, it simply emits an empty list of further messages. In other word, no reaction.

### when ended

When the node is in the status "ended" and it gets a "receive" message, it simply emits an empty list of further messages. In other word, no reaction.

## on cancel

TODO

## on kill

TODO

