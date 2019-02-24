
# flor

[![Build Status](https://secure.travis-ci.org/floraison/flor.svg)](http://travis-ci.org/floraison/flor)
[![Gem Version](https://badge.fury.io/rb/flor.svg)](http://badge.fury.io/rb/flor)

Flor is a "Ruby workflow engine", if that makes any sense.

* [![Join the chat at https://gitter.im/floraison/flor](https://badges.gitter.im/floraison/flor.svg)](https://gitter.im/floraison/flor?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
* [floraison mailing list](https://groups.google.com/forum/#!forum/floraison)
* [twitter.com/@flor_workflow](https://twitter.com/flor_workflow)

## design

* Strives to propose a scheming interpreter for long running executions
* Is written in Ruby, a rather straightforward language with at least two
  wonderful implementations (MRI and JRuby, which is enterprise-friendly)
* Stores everything as JSON (if it breaks it's still readable)
* Stores in any database supported by [Sequel](http://sequel.jeremyevans.net/)
  (the JSON goes in the "content" columns, along with some index columns)
* Favours naive/simple implementations over smart ones
* All in all should be easy to maintain (engine itself and executions running
  on top of it)

## quickstart

See [quickstart/](quickstart/).

## documentation

See [doc/](doc/).

* [doc/procedures/](doc/procedures/#procedures) - the basic building blocks of the flor language
* [doc/glossary](doc/glossary.md) - words and their meaning in the flor context
* [doc/patterns](doc/patterns.md) - workflow patterns and their flor (tentative) implementations

## related projects

* [mantor/floristry](https://github.com/mantor/floristry) - visualize and interact with flor through Rails facilities
* [floraison/pollen](https://github.com/floraison/pollen) - a set of flor hooks that emit over the http
* [floraison/florist](https://github.com/floraison/florist) - a flor worklist implementation
* [floraison/flack](https://github.com/floraison/flack) - a flor wrapping [Rack](https://github.com/rack/rack) app

* [floraison/fugit](https://github.com/floraison/fugit) - a time library for flor and [rufus-scheduler](https://github.com/jmettraux/rufus-scheduler)
* [floraison/raabro](https://github.com/floraison/raabro) - the PEG library flor uses for its parsing needs

## blog posts and presentations

* [the flor language](http://jmettraux.skepti.ch/20180927.html?t=the_flor_language) - on the flor workflow definition language itself
* [Flor, hubristic interpreter](http://rubykaigi.org/2017/presentations/jmettraux.html) - RubyKaigi 2017, Hiroshima - presentation
* [flor design 0](http://jmettraux.skepti.ch/20171021.html?t=flor_design_0&f=readme) - running a simple execution, what happens - blog post
* [flor, branch to branch](https://speakerdeck.com/jmettraux/flor-branch-to-branch) - q1 2017 - very dry deck
* [flor 2017](https://speakerdeck.com/jmettraux/flor-2017) - q1 2017 - very dry deck


## license

MIT, see [LICENSE.txt](LICENSE.txt)

