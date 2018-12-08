
# procedures

## core

* [_arr](_arr.md) - "_arr" is the procedure behind arrays.
* [_obj](_obj.md) - "_obj" is the procedure behind objects (maps).
* [_skip](_skip.md) - Skips x messages, mostly used for testing flor.
* [all?](all.md) - Returns true if all the elements in a collection return true for the given function.
* [and, or](andor.md) - When `and` evaluates the children and returns false as soon as one of returns a falsy value. Returns true else. When `or` evaluates the children and returns true as soon as one of them returns a trueish value. Returns false else.
* [any?](any.md) - Returns `true` if at least one of the member of a collection returns something trueish for the given function. Returns `false` else.
* [apply](apply.md) - Applies a function.
* [+, -, *, /, %](arith.md) - The base implementation for + - + / %
* [array?, object?, boolean?, number?, string?, null?, list?, dict?, hash?, nil?, false?, true?, pair?, float?](array_qmark.md) - Returns true if the argument or the incoming ret matches in type.
* [break, continue](break.md) - Breaks or continues a "while", "until", "loop" or an "cursor".
* [case](case.md) - The classical case form.
* [collect](collect.md) - A simplified version of [map](map.md).
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
* [flatten](flatten.md) - Flattens the given array
* [for-each](for_each.md) - Calls a function for each element in the argument collection.
* [if, unless, ife, unlesse](if.md) - The classical "if" (and its "unless" sidekick)
* [inject](inject.md) - A simplified version of [reduce](reduce.md).
* [keys, values](keys.md) - Returns the "keys" or the "values" of an object.
* [length, size](length.md) - Returns the length of its last collection argument or the length of the incoming f.ret
* [loop](loop.md) - Executes child expressions in sequence, then loops around.
* [map](map.md) - This is the classical "map" procedure. It accepts a collection and a function and yields a new collection.
* [match](match.md) - A kind of "destructuring [case](case.md)".
* [matchr, match?, pmatch](matchr.md) - Matches a string against a regular expression.
* [merge](merge.md) - Merges objects or arrays.
* [move](move.md) - Moves a cursor to a given position, a kind of local goto.
* [noeval](noeval.md) - Immediately replies, children are not evaluated
* [noret](noret.md) - Executes its children, but doesn't alter the received f.ret
* [not](not.md) - Negates its last child (or its last unkeyed attribute)
* [on](on.md) - Catches signals or errors.
* [on_cancel](on_cancel.md) - Counterpart to the on_cancel: attribute.
* [on_error](on_error.md) - Counterpart to the on_error: attribute.
* [push, pushr](push.md) - Pushes a value into an array (in a variable or a field).
* [rand](rand.md) - Returns a randomly generated number.
* [range](range.md) - Generates ranges of integers.
* [reduce](reduce.md) - Takes a collection and a function, reduces the collection to a single result thanks to the function.
* [reverse](reverse.md) - Reverses an array or a string.
* [select, reject](select.md) - Filters a collection
* [sequence, _apply, begin](sequence.md) - Executes child expressions in sequence.
* [set, setr](set.md) - Sets a field or a variable.
* [shuffle, sample](shuffle.md) - Returns a shuffled version of an array.
* [slice, index](slice.md) - Takes an array or a string and returns a slice of it (a new array or a new string).
* [sort](sort.md) - Sorts an array or an object.
* [stall](stall.md) - Mostly used in flor tests. Stalls the current branch of execution.
* [downcase, lowercase, lowcase, upcase, uppercase, capitalize, trim, strip, snakecase, snake_case, camelcase, camelCase](strings.md) - "downcase", "upcase", "capitalize", etc.
* [timestamp, ltimestamp](timestamp.md) - Places a string timestamp in f.ret.
* [to-array, to-object](to_array.md) - Turns the argument into an array or an object.
* [type-of, type](type_of.md) - returns the type of argument or the incoming f.ret.
* [until, while](until.md) - Loops until or while a condiation evalutates to true.

## unit

* [cancel, kill](cancel.md) - Cancels an execution branch
* [ccollect](ccollect.md) - A concurrent version of [collect](collect.md).
* [cmap](cmap.md) - Concurrent version of "map". Spins a concurrent child for each element of the incoming/argument collection.
* [concurrence](concurrence.md) - Executes its children concurrently.
* [cron](cron.md) - A macro-procedure, rewriting itself to `schedule cron: ...`.
* [do-trap](do_trap.md) - A version of trap that accepts a block instead of a function.
* [every](every.md) - A macro-procedure, rewriting itself to `schedule every: ...`.
* [graft, import](graft.md) - Graft a subtree into the current execution.
* [on_timeout](on_timeout.md) - Counterpart to the on_timeout: attribute.
* [schedule](schedule.md) - Schedules a function in time.
* [signal](signal.md) - Used in conjuction with "on".
* [sleep](sleep.md) - Makes a branch of an execution sleep for a while.
* [task](task.md) - Tasks a tasker with a task.
* [trap](trap.md) - Watches the messages emitted in the execution and reacts when a message matches certain criteria.


## core and unit tree

* [Flor::Procedure](https://github.com/floraison/flor/blob/master/) : 
  * [Flor::Macro](https://github.com/floraison/flor/blob/master/) : 
    * [Flor::Pro::DoReturn](https://github.com/floraison/flor/blob/master/lib/flor/pcore/do_return.rb) : [do-return](do_return.md)
    * [Flor::Pro::DoTrap](https://github.com/floraison/flor/blob/master/lib/flor/punit/do_trap.rb) : [do-trap](do_trap.md)
    * [Flor::Pro::On](https://github.com/floraison/flor/blob/master/lib/flor/pcore/on.rb) : [on](on.md)
  * [Flor::Pro::Andor](https://github.com/floraison/flor/blob/master/lib/flor/pcore/andor.rb) : [and, or](andor.md)
  * [Flor::Pro::Apply](https://github.com/floraison/flor/blob/master/lib/flor/pcore/apply.rb) : [apply](apply.md)
  * [Flor::Pro::Arith](https://github.com/floraison/flor/blob/master/lib/flor/pcore/arith.rb) : +, -, *, /, %
  * [Flor::Pro::ArrayQmark](https://github.com/floraison/flor/blob/master/lib/flor/pcore/array_qmark.rb) : [array?, object?, boolean?, number?, string?, null?, list?, dict?, hash?, nil?, false?, true?, pair?, float?](array_qmark.md)
  * [Flor::Pro::Atom](https://github.com/floraison/flor/blob/master/lib/flor/pcore/_atom.rb) : _num, _boo, _sqs, _nul, _func
  * [Flor::Pro::Att](https://github.com/floraison/flor/blob/master/lib/flor/pcore/_att.rb) : _att
  * [Flor::Pro::Break](https://github.com/floraison/flor/blob/master/lib/flor/pcore/break.rb) : [break, continue](break.md)
  * [Flor::Pro::Cancel](https://github.com/floraison/flor/blob/master/lib/flor/punit/cancel.rb) : [cancel, kill](cancel.md)
  * [Flor::Pro::Case](https://github.com/floraison/flor/blob/master/lib/flor/pcore/case.rb) : [case](case.md)
    * [Flor::Pro::Match](https://github.com/floraison/flor/blob/master/lib/flor/pcore/match.rb) : [match](matchr.md)
  * [Flor::Pro::Cmap](https://github.com/floraison/flor/blob/master/lib/flor/punit/cmap.rb) : [cmap](cmap.md)
  * [Flor::Pro::Cmp](https://github.com/floraison/flor/blob/master/lib/flor/pcore/cmp.rb) : =, ==, <, >, <=, >=, !=, <>
  * [Flor::Pro::Coll](https://github.com/floraison/flor/blob/master/lib/flor/pcore/_coll.rb) : 
    * [Flor::Pro::Arr](https://github.com/floraison/flor/blob/master/lib/flor/pcore/_arr.rb) : [_arr](_arr.md)
    * [Flor::Pro::Obj](https://github.com/floraison/flor/blob/master/lib/flor/pcore/_obj.rb) : [_obj](_obj.md)
  * [Flor::Pro::Concurrence](https://github.com/floraison/flor/blob/master/lib/flor/punit/concurrence.rb) : [concurrence](concurrence.md)
  * [Flor::Pro::Cond](https://github.com/floraison/flor/blob/master/lib/flor/pcore/cond.rb) : [cond](cond.md)
  * [Flor::Pro::Cursor](https://github.com/floraison/flor/blob/master/lib/flor/pcore/cursor.rb) : [cursor](cursor.md)
    * [Flor::Pro::Loop](https://github.com/floraison/flor/blob/master/lib/flor/pcore/loop.rb) : [loop](loop.md)
  * [Flor::Pro::Define](https://github.com/floraison/flor/blob/master/lib/flor/pcore/define.rb) : [def, fun, define](define.md)
  * [Flor::Pro::Dmute](https://github.com/floraison/flor/blob/master/lib/flor/pcore/_dmute.rb) : _dmute
  * [Flor::Pro::Dol](https://github.com/floraison/flor/blob/master/lib/flor/pcore/_dol.rb) : _dol
  * [Flor::Pro::DoubleQuoteString](https://github.com/floraison/flor/blob/master/lib/flor/pcore/_dqs.rb) : _dqs
  * [Flor::Pro::Dump](https://github.com/floraison/flor/blob/master/lib/flor/pcore/_dump.rb) : _dump
  * [Flor::Pro::Echo](https://github.com/floraison/flor/blob/master/lib/flor/pcore/echo.rb) : echo
  * [Flor::Pro::Empty](https://github.com/floraison/flor/blob/master/lib/flor/pcore/empty.rb) : [empty?](empty.md)
  * [Flor::Pro::Err](https://github.com/floraison/flor/blob/master/lib/flor/pcore/_err.rb) : _err
  * [Flor::Pro::Fail](https://github.com/floraison/flor/blob/master/lib/flor/pcore/fail.rb) : [fail, error](fail.md)
  * [Flor::Pro::Flatten](https://github.com/floraison/flor/blob/master/lib/flor/pcore/flatten.rb) : [flatten](flatten.md)
  * [Flor::Pro::Graft](https://github.com/floraison/flor/blob/master/lib/flor/punit/graft.rb) : [graft, import](graft.md)
  * [Flor::Pro::Head](https://github.com/floraison/flor/blob/master/lib/flor/pcore/_head.rb) : _head
  * [Flor::Pro::If](https://github.com/floraison/flor/blob/master/lib/flor/pcore/if.rb) : [if, unless, ife, unlesse](if.md)
  * [Flor::Pro::Includes](https://github.com/floraison/flor/blob/master/lib/flor/pcore/includes.rb) : includes?
  * [Flor::Pro::Iterator](https://github.com/floraison/flor/blob/master/lib/flor/pcore/iterator.rb) : 
    * [Flor::Pro::All](https://github.com/floraison/flor/blob/master/lib/flor/pcore/all.rb) : [all?](all.md)
    * [Flor::Pro::Filter](https://github.com/floraison/flor/blob/master/lib/flor/pcore/filter.rb) : [filter, filter-out](filter.md)
    * [Flor::Pro::Find](https://github.com/floraison/flor/blob/master/lib/flor/pcore/find.rb) : [find](find.md)
      * [Flor::Pro::Any](https://github.com/floraison/flor/blob/master/lib/flor/pcore/any.rb) : [any?](any.md)
    * [Flor::Pro::ForEach](https://github.com/floraison/flor/blob/master/lib/flor/pcore/for_each.rb) : [for-each](for_each.md)
    * [Flor::Pro::Map](https://github.com/floraison/flor/blob/master/lib/flor/pcore/map.rb) : [map](map.md)
    * [Flor::Pro::Reduce](https://github.com/floraison/flor/blob/master/lib/flor/pcore/reduce.rb) : [reduce](reduce.md)
    * [Flor::Pro::SortBy](https://github.com/floraison/flor/blob/master/lib/flor/pcore/sort_by.rb) : sort_by
  * [Flor::Pro::Keys](https://github.com/floraison/flor/blob/master/lib/flor/pcore/keys.rb) : [keys, values](keys.md)
  * [Flor::Pro::Length](https://github.com/floraison/flor/blob/master/lib/flor/pcore/length.rb) : [length, size](length.md)
  * [Flor::Pro::Matchr](https://github.com/floraison/flor/blob/master/lib/flor/pcore/matchr.rb) : [matchr, match?, pmatch](matchr.md)
  * [Flor::Pro::Merge](https://github.com/floraison/flor/blob/master/lib/flor/pcore/merge.rb) : [merge](merge.md)
  * [Flor::Pro::Move](https://github.com/floraison/flor/blob/master/lib/flor/pcore/move.rb) : [move](move.md)
  * [Flor::Pro::NoEval](https://github.com/floraison/flor/blob/master/lib/flor/pcore/noeval.rb) : [noeval](noeval.md)
  * [Flor::Pro::NoRet](https://github.com/floraison/flor/blob/master/lib/flor/pcore/noret.rb) : [noret](noret.md)
  * [Flor::Pro::Not](https://github.com/floraison/flor/blob/master/lib/flor/pcore/not.rb) : [not](not.md)
  * [Flor::Pro::OnCancel](https://github.com/floraison/flor/blob/master/lib/flor/pcore/on_cancel.rb) : [on_cancel](on_cancel.md)
  * [Flor::Pro::OnError](https://github.com/floraison/flor/blob/master/lib/flor/pcore/on_error.rb) : [on_error](on_error.md)
  * [Flor::Pro::OnTimeout](https://github.com/floraison/flor/blob/master/lib/flor/punit/on_timeout.rb) : [on_timeout](on_timeout.md)
  * [Flor::Pro::Part](https://github.com/floraison/flor/blob/master/lib/flor/punit/part.rb) : part, flank
  * [Flor::Pro::PatContainer](https://github.com/floraison/flor/blob/master/lib/flor/pcore/_pat_.rb) : 
    * [Flor::Pro::PatArr](https://github.com/floraison/flor/blob/master/lib/flor/pcore/_pat_arr.rb) : _pat_arr
    * [Flor::Pro::PatGuard](https://github.com/floraison/flor/blob/master/lib/flor/pcore/_pat_guard.rb) : _pat_guard
    * [Flor::Pro::PatObj](https://github.com/floraison/flor/blob/master/lib/flor/pcore/_pat_obj.rb) : _pat_obj
    * [Flor::Pro::PatOr](https://github.com/floraison/flor/blob/master/lib/flor/pcore/_pat_or.rb) : _pat_or
    * [Flor::Pro::PatRegex](https://github.com/floraison/flor/blob/master/lib/flor/pcore/_pat_regex.rb) : _pat_regex
  * [Flor::Pro::Push](https://github.com/floraison/flor/blob/master/lib/flor/pcore/push.rb) : [push, pushr](push.md)
  * [Flor::Pro::Rand](https://github.com/floraison/flor/blob/master/lib/flor/pcore/rand.rb) : [rand](rand.md)
  * [Flor::Pro::Range](https://github.com/floraison/flor/blob/master/lib/flor/pcore/range.rb) : [range](range.md)
  * [Flor::Pro::Ref](https://github.com/floraison/flor/blob/master/lib/flor/pcore/_ref.rb) : _ref, _rep
  * [Flor::Pro::RegularExpressionString](https://github.com/floraison/flor/blob/master/lib/flor/pcore/_rxs.rb) : _rxs
  * [Flor::Pro::Return](https://github.com/floraison/flor/blob/master/lib/flor/pcore/return.rb) : return
  * [Flor::Pro::Reverse](https://github.com/floraison/flor/blob/master/lib/flor/pcore/reverse.rb) : [reverse](reverse.md)
  * [Flor::Pro::Schedule](https://github.com/floraison/flor/blob/master/lib/flor/punit/schedule.rb) : [schedule](schedule.md)
  * [Flor::Pro::Sequence](https://github.com/floraison/flor/blob/master/lib/flor/pcore/sequence.rb) : [sequence, _apply, begin](sequence.md)
  * [Flor::Pro::Set](https://github.com/floraison/flor/blob/master/lib/flor/pcore/set.rb) : [set, setr](set.md)
  * [Flor::Pro::Shuffle](https://github.com/floraison/flor/blob/master/lib/flor/pcore/shuffle.rb) : [shuffle, sample](shuffle.md)
  * [Flor::Pro::Signal](https://github.com/floraison/flor/blob/master/lib/flor/punit/signal.rb) : [signal](signal.md)
  * [Flor::Pro::Skip](https://github.com/floraison/flor/blob/master/lib/flor/pcore/_skip.rb) : [_skip](_skip.md)
  * [Flor::Pro::Sleep](https://github.com/floraison/flor/blob/master/lib/flor/punit/sleep.rb) : [sleep](sleep.md)
  * [Flor::Pro::Slice](https://github.com/floraison/flor/blob/master/lib/flor/pcore/slice.rb) : [slice, index](slice.md)
  * [Flor::Pro::Sort](https://github.com/floraison/flor/blob/master/lib/flor/pcore/sort.rb) : [sort](sort.md)
  * [Flor::Pro::Split](https://github.com/floraison/flor/blob/master/lib/flor/pcore/split.rb) : split
  * [Flor::Pro::Stall](https://github.com/floraison/flor/blob/master/lib/flor/pcore/stall.rb) : [stall](stall.md)
  * [Flor::Pro::Strings](https://github.com/floraison/flor/blob/master/lib/flor/pcore/strings.rb) : [downcase, lowercase, lowcase, upcase, uppercase, capitalize, trim, strip, snakecase, snake_case, camelcase, camelCase](strings.md)
  * [Flor::Pro::Task](https://github.com/floraison/flor/blob/master/lib/flor/punit/task.rb) : [task](task.md)
  * [Flor::Pro::TimeStamp](https://github.com/floraison/flor/blob/master/lib/flor/pcore/timestamp.rb) : [timestamp, ltimestamp](timestamp.md)
  * [Flor::Pro::ToArray](https://github.com/floraison/flor/blob/master/lib/flor/pcore/to_array.rb) : [to-array, to-object](to_array.md)
  * [Flor::Pro::Trace](https://github.com/floraison/flor/blob/master/lib/flor/punit/trace.rb) : trace
  * [Flor::Pro::Trap](https://github.com/floraison/flor/blob/master/lib/flor/punit/trap.rb) : [trap](trap.md)
  * [Flor::Pro::Twig](https://github.com/floraison/flor/blob/master/lib/flor/pcore/twig.rb) : twig
  * [Flor::Pro::TypeOf](https://github.com/floraison/flor/blob/master/lib/flor/pcore/type_of.rb) : [type-of, type](type_of.md)
  * [Flor::Pro::Until](https://github.com/floraison/flor/blob/master/lib/flor/pcore/until.rb) : [until, while](until.md)
  * [Flor::Pro::Val](https://github.com/floraison/flor/blob/master/lib/flor/pcore/_val.rb) : _val

