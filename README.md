
# flor

[![Build Status](https://secure.travis-ci.org/floraison/flor.svg)](http://travis-ci.org/floraison/flor)
[![Gem Version](https://badge.fury.io/rb/flor.svg)](http://badge.fury.io/rb/flor)

Flor is a "Ruby workflow engine", if that makes any sense.

* [![Join the chat at https://gitter.im/floraison/flor](https://badges.gitter.im/floraison/flor.svg)](https://gitter.im/floraison/flor?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
* [floraison mailing list](https://groups.google.com/forum/#!forum/floraison)

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

## Quickstart

See [quickstart/](quickstart/).

## Documentation

See [doc/](doc/).


## LICENSE

MIT, see [LICENSE.txt](LICENSE.txt)

