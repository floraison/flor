
# flor

[![Build Status](https://secure.travis-ci.org/floraison/flor.svg)](http://travis-ci.org/floraison/flor)
[![Gem Version](https://badge.fury.io/rb/flor.svg)](http://badge.fury.io/rb/flor)

Flor is a "Ruby workflow engine", if that makes any sense.

## Design

* Strives to propose a scheming interpreter for long running executions
* Is written in Ruby a rather straightforward language with at least two
  wonderful implementations (MRI and JRuby, which is enterprise-friendly)
* Stores everything as JSON (if it breaks it's still readable)
* Stores in any database supported by [Sequel](http://sequel.jeremyevans.net/)
  (the JSON goes in the "content" columns, along with some index columns)
* Favours naive/simple implementations over smart ones
* All in all should be easy to maintain (engine itself and executions running
  on top of it)

## Documentation

see [doc/](doc/).

## Running the specs

(Most of the time, as developer of flor, I'm writing specs, running them with `FLOR_DEBUG=dbg` and hammering the code until the specs are green. The following lines are about setting `FLOR_DEBUG` for flor development).

##### setting FLOR_DEBUG

This is a targetted run of a spec file:
```
FLOR_DEBUG=msg,err bundle exec rspec spec/punit/cancel_spec.rb
```

* `msg` displays the flor messages in a summary, colored format
* `err` displays errors with details, when and if they happen
* `src` displays the source before it gets parsed and launched
* `tree` displays the syntax tree as parsed from the source, right before launch
* `run` shows info about each [run](doc/glossary.md#run) that just ended
* `sto` displays debug information about the [storage](doc/glossary.md#storage), it's mostly SQL statements

#### `FLOR_DEBUG=dbg` and `FLOR_DEBUG=all`

There are two shortcuts for the flags above:
```
FLOR_DEBUG=dbg bundle exec rspec spec/punit/cancel_spec.rb
  # is equivalent to
FLOR_DEBUG=msg,err,src,tree,run bundle exec rspec spec/punit/cancel_spec.rb
```
and
```
FLOR_DEBUG=all bundle exec rspec spec/punit/cancel_spec.rb
  # is equivalent to
FLOR_DEBUG=msg,err,src,tree,run,log,sto bundle exec rspec spec/punit/cancel_spec.rb
```

I tend to use `FLOR_DEBUG=dbg` when developping flor.


## LICENSE

MIT, see [LICENSE.txt](LICENSE.txt)

