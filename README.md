
# flor

[![Build Status](https://secure.travis-ci.org/floraison/flor.svg)](http://travis-ci.org/floraison/flor)
[![Gem Version](https://badge.fury.io/rb/flor.svg)](http://badge.fury.io/rb/flor)

Flor is a "Ruby workflow engine", if that makes any sense.

* [![Join the chat at https://gitter.im/floraison/flor](https://badges.gitter.im/floraison/flor.svg)](https://gitter.im/floraison/flor?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
* [floraison mailing list](https://groups.google.com/forum/#!forum/floraison)
* [twitter.com/@flor_workflow](https://twitter.com/flor_workflow)


## use

As a workflow engine, flor takes as input process definitions and executes them. Those executions may in turn call pieces of Ruby code or external scripts that perform the actual work. Those pieces of code and scripts are called "taskers".

The classical way to use a language interpreter is to instantiate it as needed and let it die as the host execution ends. A workflow engine is more like a server, it may host multiple executions. And if the workflow engine stops, it may be restarted and pick the work back, when it was when it stopped.

Flor process definitions are written in the flor language, a programming language mostly inspired by Scheme and Ruby. As always with programming languages, readability is hoped for, for a workflow engine this is especially necessary since those business processes are the bread and butter of business users.

Using flor in your Ruby project requires you to clearly separate business process definitions from taskers. Since a flor instance may host multiple process executions based on one or more process definitions, many of the taskers may be reused from one definition to the other. For instance, if a "send-invoice-to-customer" tasker is created it might get used in the "process-retail-order" and the "process-big-distribution-order" processes.


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

This quickstart sets up a flor unit tied to a SQLite database, resets the databse, binds two taskers and then launches a flow execution involving the two taskers. Finally, it prints out the resulting workitem as the execution has just terminated.

```ruby
require 'flor/unit'

#ENV['FLOR_DEBUG'] = 'dbg,sto,stdout' # full sql + flor debug output
#ENV['FLOR_DEBUG'] = 'dbg,stdout' # flor debug output
  # uncomment to see the flor activity

sto_uri = 'sqlite://flor_qs.db'
sto_uri = 'jdbc:sqlite://flor_qs.db' if RUBY_PLATFORM.match(/java/)

flor = Flor::Unit.new(loader: Flor::HashLoader, sto_uri: sto_uri)
  # instantiate flor unit

flor.storage.delete_tables
flor.storage.migrate
  # blank slate database

class DemoTasker < Flor::BasicTasker
  def task(message)
    (attd['times'] || 1).times do
      message['payload']['log'] << "#{tasker}: #{task_name}"
    end
    reply
  end
end
flor.add_tasker(:alice, DemoTasker)
flor.add_tasker(:bob, DemoTasker)
  # a simple logging tasker implementation bound under
  # two different tasker names

flor.start
  # start the flor unit, so that it can process executions

exid = flor.launch(
  %q{
    sequence
      alice 'hello' times: 2
      bob 'world'
  },
  payload: { log: [ "started at #{Time.now}" ] })
    # launch a new execution, one that chains alice and bob work

#r = flor.wait(exid, 'terminated')
r = flor.wait(exid)
  # wait for the execution to terminate or to fail

p r['point']
  # "terminated" hopefully
p r['payload']['log']
  # [ "started at 2019-03-31 10:20:18 +0900",
  #   "alice: hello", "alice: hello",
  #   "bob: world" ]
```

This quickstart is at [doc/quickstart0/](doc/quickstart0/), it's a minimal, one-file Ruby quickstart.

There is also [doc/quickstart1/](doc/quickstart1/), a more complex example, that shows a flor setup, where taskers and flows are layed out in a flor directory tree.


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

* [flor workflow engine](http://jmettraux.skepti.ch/20190407.html?t=flor_workflow_engine&f=readme) - on flor itself
* [the flor language](http://jmettraux.skepti.ch/20180927.html?t=the_flor_language&f=readme) - on the flor workflow definition language itself
* [reddit answer on workflow engines](http://jmettraux.skepti.ch/20190416.html?t=reddit_answer_on_workflow_engines&f=readme) - an answer to a Reddit question on workflow engines, archived as a post
* [Flor, hubristic interpreter](http://rubykaigi.org/2017/presentations/jmettraux.html) - RubyKaigi 2017, Hiroshima - presentation
* [flor design 0](http://jmettraux.skepti.ch/20171021.html?t=flor_design_0&f=readme) - running a simple execution, what happens - blog post
* [flor, branch to branch](https://speakerdeck.com/jmettraux/flor-branch-to-branch) - q1 2017 - very dry deck
* [flor 2017](https://speakerdeck.com/jmettraux/flor-2017) - q1 2017 - very dry deck


## other Ruby projects about workflows

There are various other Ruby and Ruby on Rails projects about workflows and business processes, each with its own take on them.

* [Dynflow](http://dynflow.github.io/) - "Dynflow (DYNamic workFLOW) is a workflow engine written in Ruby"
* [rails_workflow](https://github.com/madzhuga/rails_workflow) - "Rails Workflow Engine allows you to organize your application business logic by joining user- and auto- operations in processes"
* [rails_engine/flow_core](https://github.com/rails-engine/flow_core) - "A multi purpose, extendable, Workflow-net-based workflow engine for Rails applications"
* [Trailblazer](http://trailblazer.to/) - "The Advanced Business Logic Framework"
* [Petri Flow](https://github.com/hooopo/petri_flow) - "Petri Net Workflow Engine for Ruby" (Rails)
* [Pallets](https://github.com/linkyndy/pallets) - "Simple and reliable workflow engine, written in Ruby"
* [Gush](https://github.com/chaps-io/gush) - "Fast and distributed workflow runner using ActiveJob and Redis"

There is a [workflow engine](https://ruby.libhunt.com/categories/5786-workflow-engine) category on [Awesome Ruby](https://ruby.libhunt.com/).

If you want your engine/library to be added in this list, don't hesitate to ask me on [Gitter](https://gitter.im/floraison/flor) or via a pull request.

It's not limited to Ruby, but there is a wider list at [meirwah/awesome-workflow-engines](https://github.com/meirwah/awesome-workflow-engines).


## license

MIT, see [LICENSE.txt](LICENSE.txt)

