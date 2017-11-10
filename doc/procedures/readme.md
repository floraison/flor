
# procedures

## core

* [_arr](_arr.md) - "_arr" is the procedure behind arrays.
* [_obj](_obj.md) - "_obj" is the procedure behind objects (maps).
* [_skip](_skip.md) - Skips x messages, mostly used for testing flor.
* [apply](apply.md) - Applies a function.
* [break, continue](break.md) - Breaks or continues a "while" or "until".
* [case](case.md) - The classical case form.
* [collect](collect.md) - Collect is a simplified version of [map](map.md).
* [cond](cond.md) - Evaluates all its condition children until one evaluates to true (or it's an else), then executes the corresponding clause child.
* [cursor](cursor.md) - Executes child expressions in sequence, but may be "guided".
* [def, fun, define](define.md) - Defines a function.
* [do-return](do_return.md) - Takes a set of arguments and returns a function that will return those arguments again.
* [fail, error](fail.md) - Explicitely raises an error.
* [filter, filter-out](filter.md) - Filters a collection
* [for-each](for_each.md) - Calls a function for each element in the argument collection.
* [if, unless, ife, unlesse](if.md) - The classical "if" (and its "unless" sidequick)
* [length](length.md) - Returns the length of its last collection argument or the length of the incoming f.ret
* [and, or](logo.md) - When `and` evaluates the children and returns false as soon as one of returns a falsy value. Returns true else. When `or` evaluates the children and returns true as soon as one of them returns a trueish value. Returns false else.
* [loop](loop.md) - Executes child expressions in sequence, then loops around.
* [map](map.md) - This is the classical "map" procedure. It accepts a collection and a function and yields a new collection.
* [match](match.md) - "match" can be thought of as a "destructuring [case](case.md)".
* [matchr, match?](matchr.md) - Matches a string against a regular expression.
* [move](move.md) - Moves a cursor to a given position, a kind of local goto.
* [noeval](noeval.md) - Immediately replies, children are not evaluated
* [noret](noret.md) - executes its children, but doesn't alter the received f.ret
* [push, pushr](push.md) - Pushes a value into an array (in a variable or a field).
* [rand](rand.md) - Returns a randomly generated number.
* [range](range.md) - "range" is a procedure to generate ranges of integers.
* [reverse](reverse.md) - Reverses an array or a string.
* [select](select.md) - Filters a collection
* [sequence, _apply, begin](sequence.md) - Executes child expressions in sequence.
* [set, setr](set.md) - sets a field or a variable.
* [to-array, to-object](to_array.md) - "to-array", turns an argument into an array, "to-object" turns it into an object.

## unit

* [cancel, kill](cancel.md) - Cancels an execution branch
* [concurrence](concurrence.md) - Executes its children concurrently.
* [cron](cron.md) - "cron" is a macro procedure.
* [every](every.md) - "every" is a macro procedure.
* [graft, import](graft.md) - Graft a subtree into the current flo
* [on](on.md) - Traps a signal by name
* [schedule](schedule.md) - Schedules a function
* [sleep](sleep.md) - Makes a branch of an execution sleep for a while.

