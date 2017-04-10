
# node.md

## the node itself

A node is a JSON document with a least those entries:

* nid: the "node id"
* parent: may be null, contains the nid of the parent node
* cnodes: may be null (thus considered as an empty array), an array of the nids of the child nodes
* status: an array of hashes

## procedure

A procedure wraps a node and regulates the behaviour of the node with regard to its parent node (if any) and its child nodes (if any).

The simplest procedure is the "sequence", with this, default, behaviour:

## on execute

Node gets added to the "nodes" entry of the execution.

If the node has a parent, the node id gets added to the "cnodes" entry of the parent node.

## on receive

(the node emitting the 'receive' message is removed unless it is flanking, `point: receive, flavour: flanking`)

The last element of nid of the incoming message is used to determine if the next child has to be applied. If there is no next child, the node replies to its parent node by sending it a "receive" message.

If there is no parent, no "receive" message is emitted, but a "ceased" or a "terminated" message is emitted. "ceased" is emitted if the emitting node is different from "0", thus "terminated" is only emitted by the root "0" node.

## on cancel

TODO

## on kill

TODO

