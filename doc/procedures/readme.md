
# procedures

## core

* [_skip](_skip.md) - Skips x messages, mostly used for testing flor.
* [break, continue](break.md) - Breaks or continues a "while" or "until".
* [cursor](cursor.md) - Executes child expressions in sequence, but may be "guided".
* [def, fun, define](define.md) - Defines a function.
* [loop](loop.md) - Executes child expressions in sequence, then loops around.
* [move](move.md) - Moves a cursor to a given position
* [noeval](noeval.md) - Immediately replies, children are not evaluated
* [noret](noret.md) - executes its children, but doesn't alter the received f.ret
* [rand](rand.md) - Returns a randomly generated number.
* [sequence, _apply, begin](sequence.md) - Executes child expressions in sequence.

## unit

* [cancel, kill](cancel.md) - Cancels an execution branch
* [schedule](schedule.md) - Schedules a function
* [sleep](sleep.md) - Makes a branch of an execution sleep for a while.

