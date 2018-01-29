
# procedures

## core

* [_arr](_arr.md) - "_arr" is the procedure behind arrays.
* [_obj](_obj.md) - "_obj" is the procedure behind objects (maps).
* [_skip](_skip.md) - Skips x messages, mostly used for testing flor.
* [all?](all.md) - Returns true if all the elements in a collection return true for the given function.
* [any?](any.md) - Returns `true` if at least one of the member of a collection returns something trueish for the given function. Returns `false` else.
* [apply](apply.md) - Applies a function.
* [break, continue](break.md) - Breaks or continues a "while" or "until".
* [case](case.md) - The classical case form.
* [collect](collect.md) - Collect is a simplified version of [map](map.md).
* [cond](cond.md) - Evaluates all its condition children until one evaluates to true (or it's an else), then executes the corresponding clause child.
* [cursor](cursor.md) - Executes child expressions in sequence, but may be "guided".
* [def, fun, define](define.md) - Defines a function.
* [detect](detect.md) - Detect is a simplified version of [find](find.md).
* [do-return](do_return.md) - Takes a set of arguments and returns a function that will return those arguments again.
* [each](each.md) - Each is a simplified version of [for-each](for_each.md).
* [empty?](empty.md) - Returns true if the given collection or string is empty.
* [fail, error](fail.md) - Explicitely raises an error.
* [filter, filter-out](filter.md) - Filters a collection
* [find](find.md) - Finds the first matching element.
* [for-each](for_each.md) - Calls a function for each element in the argument collection.
* [if, unless, ife, unlesse](if.md) - The classical "if" (and its "unless" sidequick)
* [inject](inject.md) - Inject is a simplified version of [reduce](reduce.md).
* [keys, values](keys.md) - Returns the "keys" or the "values" of an object.
* [length, size](length.md) - Returns the length of its last collection argument or the length of the incoming f.ret
* [and, or](logo.md) - When `and` evaluates the children and returns false as soon as one of returns a falsy value. Returns true else. When `or` evaluates the children and returns true as soon as one of them returns a trueish value. Returns false else.
* [loop](loop.md) - Executes child expressions in sequence, then loops around.
* [map](map.md) - This is the classical "map" procedure. It accepts a collection and a function and yields a new collection.
* [match](match.md) - "match" can be thought of as a "destructuring [case](case.md)".
* [matchr, match?](matchr.md) - Matches a string against a regular expression.
* [move](move.md) - Moves a cursor to a given position, a kind of local goto.
* [noeval](noeval.md) - Immediately replies, children are not evaluated
* [noret](noret.md) - executes its children, but doesn't alter the received f.ret
* [not](not.md) - `not` negates its last child (or its last unkeyed attribute)
* [push, pushr](push.md) - Pushes a value into an array (in a variable or a field).
* [rand](rand.md) - Returns a randomly generated number.
* [range](range.md) - "range" is a procedure to generate ranges of integers.
* [reduce](reduce.md) - Reduce takes a collection and a function. It reduces the collection to a single result thanks to the function.
* [reverse](reverse.md) - Reverses an array or a string.
* [select, reject](select.md) - Filters a collection
* [sequence, _apply, begin](sequence.md) - Executes child expressions in sequence.
* [set, setr](set.md) - sets a field or a variable.
* [stall](stall.md) - "stall" is mostly used in flor tests. It simply dead ends.
* [to-array, to-object](to_array.md) - "to-array", turns an argument into an array, "to-object" turns it into an object.
* [until, while](until.md) - `until` loops until a condition evaluates to true. `while` loops while a condition evaluates to true.

## unit

* [cancel, kill](cancel.md) - Cancels an execution branch
* [concurrence](concurrence.md) - Executes its children concurrently.
* [cron](cron.md) - "cron" is a macro procedure.
* [every](every.md) - "every" is a macro procedure.
* [graft, import](graft.md) - Graft a subtree into the current flo
* [on](on.md) - Traps a signal by name
* [schedule](schedule.md) - Schedules a function
* [sleep](sleep.md) - Makes a branch of an execution sleep for a while.


## core and unit tree

* Flor::Procedure
  * Flor::Macro
    * Flor::Pro::DoReturn [do-return](do-return.md)
    * Flor::Pro::On [on](on.md)
  * Flor::Pro::Apply [apply](apply.md)
  * Flor::Pro::Arith [+](+.md), [-](-.md), [*](*.md), [/](/.md), [%](%.md)
  * Flor::Pro::Atom [_num](_num.md), [_boo](_boo.md), [_sqs](_sqs.md), [_dqs](_dqs.md), [_rxs](_rxs.md), [_nul](_nul.md), [_func](_func.md)
  * Flor::Pro::Att [_att](_att.md)
  * Flor::Pro::Break [break](break.md), [continue](continue.md)
  * Flor::Pro::Cancel [cancel](cancel.md), [kill](kill.md)
  * Flor::Pro::Case [case](case.md)
    * Flor::Pro::Match [match](match.md)
  * Flor::Pro::Cmap [cmap](cmap.md)
  * Flor::Pro::Cmp [=](=.md), [==](==.md), [<](<.md), [>](>.md)
  * Flor::Pro::Coll
    * Flor::Pro::Arr [_arr](_arr.md)
    * Flor::Pro::Obj [_obj](_obj.md)
  * Flor::Pro::Concurrence [concurrence](concurrence.md)
  * Flor::Pro::Cond [cond](cond.md)
  * Flor::Pro::Cursor [cursor](cursor.md)
    * Flor::Pro::Loop [loop](loop.md)
  * Flor::Pro::Define [def](def.md), [fun](fun.md), [define](define.md)
  * Flor::Pro::Dump [_dump](_dump.md)
  * Flor::Pro::Echo [echo](echo.md)
  * Flor::Pro::Empty [empty?](empty?.md)
  * Flor::Pro::Err [_err](_err.md)
  * Flor::Pro::Fail [fail](fail.md), [error](error.md)
  * Flor::Pro::Graft [graft](graft.md), [import](import.md)
  * Flor::Pro::If [if](if.md), [unless](unless.md), [ife](ife.md), [unlesse](unlesse.md)
  * Flor::Pro::Includes [includes?](includes?.md)
  * Flor::Pro::Iterator
    * Flor::Pro::All [all?](all?.md)
    * Flor::Pro::Filter [filter](filter.md), [filter-out](filter-out.md)
    * Flor::Pro::Find [find](find.md)
      * Flor::Pro::Any [any?](any?.md)
    * Flor::Pro::ForEach [for-each](for-each.md)
    * Flor::Pro::Map [map](map.md)
    * Flor::Pro::Reduce [reduce](reduce.md)
  * Flor::Pro::Keys [keys](keys.md), [values](values.md)
  * Flor::Pro::Length [length](length.md), [size](size.md)
  * Flor::Pro::Logo [and](and.md), [or](or.md)
  * Flor::Pro::Matchr [matchr](matchr.md), [match?](match?.md)
  * Flor::Pro::Move [move](move.md)
  * Flor::Pro::NoEval [noeval](noeval.md)
  * Flor::Pro::NoRet [noret](noret.md)
  * Flor::Pro::Not [not](not.md)
  * Flor::Pro::PatContainer
    * Flor::Pro::PatArr [_pat_arr](_pat_arr.md)
    * Flor::Pro::PatGuard [_pat_guard](_pat_guard.md)
    * Flor::Pro::PatObj [_pat_obj](_pat_obj.md)
    * Flor::Pro::PatOr [_pat_or](_pat_or.md)
    * Flor::Pro::PatRegex [_pat_regex](_pat_regex.md)
  * Flor::Pro::Push [push](push.md), [pushr](pushr.md)
  * Flor::Pro::Rand [rand](rand.md)
  * Flor::Pro::Range [range](range.md)
  * Flor::Pro::Reverse [reverse](reverse.md)
  * Flor::Pro::Schedule [schedule](schedule.md)
  * Flor::Pro::Sequence [sequence](sequence.md), [_apply](_apply.md), [begin](begin.md)
  * Flor::Pro::Set [set](set.md), [setr](setr.md)
  * Flor::Pro::Signal [signal](signal.md)
  * Flor::Pro::Skip [_skip](_skip.md)
  * Flor::Pro::Sleep [sleep](sleep.md)
  * Flor::Pro::Stall [stall](stall.md)
  * Flor::Pro::Task [task](task.md)
  * Flor::Pro::ToArray [to-array](to-array.md), [to-object](to-object.md)
  * Flor::Pro::Trace [trace](trace.md)
  * Flor::Pro::Trap [trap](trap.md)
  * Flor::Pro::Twig [twig](twig.md)
  * Flor::Pro::Until [until](until.md), [while](while.md)
  * Flor::Pro::Val [_val](_val.md)

