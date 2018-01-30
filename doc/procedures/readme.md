
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

* [Flor::Procedure](https://github.com/floraison/flor/blob/master/)
  * [Flor::Macro](https://github.com/floraison/flor/blob/master/)
    * [Flor::Pro::DoReturn](https://github.com/floraison/flor/blob/master/lib/flor/pcore/do_return.rb) : [do-return](do_return.md)
    * [Flor::Pro::On](https://github.com/floraison/flor/blob/master/lib/flor/punit/on.rb) : [on](on.md)
  * [Flor::Pro::Apply](https://github.com/floraison/flor/blob/master/lib/flor/pcore/apply.rb) : [apply](apply.md)
  * [Flor::Pro::Arith](https://github.com/floraison/flor/blob/master/lib/flor/pcore/arith.rb) : +, -, *, /, %
  * [Flor::Pro::Atom](https://github.com/floraison/flor/blob/master/lib/flor/pcore/_atom.rb) : _num, _boo, _sqs, _dqs, _rxs, _nul, _func
  * [Flor::Pro::Att](https://github.com/floraison/flor/blob/master/lib/flor/pcore/_att.rb) : _att
  * [Flor::Pro::Break](https://github.com/floraison/flor/blob/master/lib/flor/pcore/break.rb) : [break, continue](break.md)
  * [Flor::Pro::Cancel](https://github.com/floraison/flor/blob/master/lib/flor/punit/cancel.rb) : [cancel, kill](cancel.md)
  * [Flor::Pro::Case](https://github.com/floraison/flor/blob/master/lib/flor/pcore/case.rb) : [case](case.md)
    * [Flor::Pro::Match](https://github.com/floraison/flor/blob/master/lib/flor/pcore/match.rb) : [match](matchr.md)
  * [Flor::Pro::Cmap](https://github.com/floraison/flor/blob/master/lib/flor/punit/cmap.rb) : cmap
  * [Flor::Pro::Cmp](https://github.com/floraison/flor/blob/master/lib/flor/pcore/cmp.rb) : =, ==, <, >
  * [Flor::Pro::Coll](https://github.com/floraison/flor/blob/master/lib/flor/pcore/_coll.rb)
    * [Flor::Pro::Arr](https://github.com/floraison/flor/blob/master/lib/flor/pcore/_arr.rb) : [_arr](_arr.md)
    * [Flor::Pro::Obj](https://github.com/floraison/flor/blob/master/lib/flor/pcore/_obj.rb) : [_obj](_obj.md)
  * [Flor::Pro::Concurrence](https://github.com/floraison/flor/blob/master/lib/flor/punit/concurrence.rb) : [concurrence](concurrence.md)
  * [Flor::Pro::Cond](https://github.com/floraison/flor/blob/master/lib/flor/pcore/cond.rb) : [cond](cond.md)
  * [Flor::Pro::Cursor](https://github.com/floraison/flor/blob/master/lib/flor/pcore/cursor.rb) : [cursor](cursor.md)
    * [Flor::Pro::Loop](https://github.com/floraison/flor/blob/master/lib/flor/pcore/loop.rb) : [loop](loop.md)
  * [Flor::Pro::Define](https://github.com/floraison/flor/blob/master/lib/flor/pcore/define.rb) : [def, fun, define](define.md)
  * [Flor::Pro::Dump](https://github.com/floraison/flor/blob/master/lib/flor/pcore/_dump.rb) : _dump
  * [Flor::Pro::Echo](https://github.com/floraison/flor/blob/master/lib/flor/pcore/echo.rb) : echo
  * [Flor::Pro::Empty](https://github.com/floraison/flor/blob/master/lib/flor/pcore/empty.rb) : empty?
  * [Flor::Pro::Err](https://github.com/floraison/flor/blob/master/lib/flor/pcore/_err.rb) : _err
  * [Flor::Pro::Fail](https://github.com/floraison/flor/blob/master/lib/flor/pcore/fail.rb) : [fail, error](fail.md)
  * [Flor::Pro::Graft](https://github.com/floraison/flor/blob/master/lib/flor/punit/graft.rb) : [graft, import](graft.md)
  * [Flor::Pro::If](https://github.com/floraison/flor/blob/master/lib/flor/pcore/if.rb) : [if, unless, ife, unlesse](if.md)
  * [Flor::Pro::Includes](https://github.com/floraison/flor/blob/master/lib/flor/pcore/includes.rb) : includes?
  * [Flor::Pro::Iterator](https://github.com/floraison/flor/blob/master/lib/flor/pcore/iterator.rb)
    * [Flor::Pro::All](https://github.com/floraison/flor/blob/master/lib/flor/pcore/all.rb) : all?
    * [Flor::Pro::Filter](https://github.com/floraison/flor/blob/master/lib/flor/pcore/filter.rb) : [filter, filter-out](filter.md)
    * [Flor::Pro::Find](https://github.com/floraison/flor/blob/master/lib/flor/pcore/find.rb) : [find](find.md)
      * [Flor::Pro::Any](https://github.com/floraison/flor/blob/master/lib/flor/pcore/any.rb) : any?
    * [Flor::Pro::ForEach](https://github.com/floraison/flor/blob/master/lib/flor/pcore/for_each.rb) : [for-each](for_each.md)
    * [Flor::Pro::Map](https://github.com/floraison/flor/blob/master/lib/flor/pcore/map.rb) : [map](map.md)
    * [Flor::Pro::Reduce](https://github.com/floraison/flor/blob/master/lib/flor/pcore/reduce.rb) : [reduce](reduce.md)
  * [Flor::Pro::Keys](https://github.com/floraison/flor/blob/master/lib/flor/pcore/keys.rb) : [keys, values](keys.md)
  * [Flor::Pro::Length](https://github.com/floraison/flor/blob/master/lib/flor/pcore/length.rb) : [length, size](length.md)
  * [Flor::Pro::Logo](https://github.com/floraison/flor/blob/master/lib/flor/pcore/logo.rb) : [and, or](logo.md)
  * [Flor::Pro::Matchr](https://github.com/floraison/flor/blob/master/lib/flor/pcore/matchr.rb) : [matchr, match?](matchr.md)
  * [Flor::Pro::Move](https://github.com/floraison/flor/blob/master/lib/flor/pcore/move.rb) : [move](move.md)
  * [Flor::Pro::NoEval](https://github.com/floraison/flor/blob/master/lib/flor/pcore/noeval.rb) : [noeval](noeval.md)
  * [Flor::Pro::NoRet](https://github.com/floraison/flor/blob/master/lib/flor/pcore/noret.rb) : [noret](noret.md)
  * [Flor::Pro::Not](https://github.com/floraison/flor/blob/master/lib/flor/pcore/not.rb) : [not](not.md)
  * [Flor::Pro::PatContainer](https://github.com/floraison/flor/blob/master/lib/flor/pcore/_pat_.rb)
    * [Flor::Pro::PatArr](https://github.com/floraison/flor/blob/master/lib/flor/pcore/_pat_arr.rb) : _pat_arr
    * [Flor::Pro::PatGuard](https://github.com/floraison/flor/blob/master/lib/flor/pcore/_pat_guard.rb) : _pat_guard
    * [Flor::Pro::PatObj](https://github.com/floraison/flor/blob/master/lib/flor/pcore/_pat_obj.rb) : _pat_obj
    * [Flor::Pro::PatOr](https://github.com/floraison/flor/blob/master/lib/flor/pcore/_pat_or.rb) : _pat_or
    * [Flor::Pro::PatRegex](https://github.com/floraison/flor/blob/master/lib/flor/pcore/_pat_regex.rb) : _pat_regex
  * [Flor::Pro::Push](https://github.com/floraison/flor/blob/master/lib/flor/pcore/push.rb) : [push, pushr](push.md)
  * [Flor::Pro::Rand](https://github.com/floraison/flor/blob/master/lib/flor/pcore/rand.rb) : [rand](rand.md)
  * [Flor::Pro::Range](https://github.com/floraison/flor/blob/master/lib/flor/pcore/range.rb) : [range](range.md)
  * [Flor::Pro::Reverse](https://github.com/floraison/flor/blob/master/lib/flor/pcore/reverse.rb) : [reverse](reverse.md)
  * [Flor::Pro::Schedule](https://github.com/floraison/flor/blob/master/lib/flor/punit/schedule.rb) : [schedule](schedule.md)
  * [Flor::Pro::Sequence](https://github.com/floraison/flor/blob/master/lib/flor/pcore/sequence.rb) : [sequence, _apply, begin](sequence.md)
  * [Flor::Pro::Set](https://github.com/floraison/flor/blob/master/lib/flor/pcore/set.rb) : [set, setr](set.md)
  * [Flor::Pro::Signal](https://github.com/floraison/flor/blob/master/lib/flor/punit/signal.rb) : signal
  * [Flor::Pro::Skip](https://github.com/floraison/flor/blob/master/lib/flor/pcore/_skip.rb) : [_skip](_skip.md)
  * [Flor::Pro::Sleep](https://github.com/floraison/flor/blob/master/lib/flor/punit/sleep.rb) : [sleep](sleep.md)
  * [Flor::Pro::Stall](https://github.com/floraison/flor/blob/master/lib/flor/pcore/stall.rb) : [stall](stall.md)
  * [Flor::Pro::Task](https://github.com/floraison/flor/blob/master/lib/flor/punit/task.rb) : task
  * [Flor::Pro::ToArray](https://github.com/floraison/flor/blob/master/lib/flor/pcore/to_array.rb) : [to-array, to-object](to_array.md)
  * [Flor::Pro::Trace](https://github.com/floraison/flor/blob/master/lib/flor/punit/trace.rb) : trace
  * [Flor::Pro::Trap](https://github.com/floraison/flor/blob/master/lib/flor/punit/trap.rb) : trap
  * [Flor::Pro::Twig](https://github.com/floraison/flor/blob/master/lib/flor/pcore/twig.rb) : twig
  * [Flor::Pro::Until](https://github.com/floraison/flor/blob/master/lib/flor/pcore/until.rb) : [until, while](until.md)
  * [Flor::Pro::Val](https://github.com/floraison/flor/blob/master/lib/flor/pcore/_val.rb) : _val

