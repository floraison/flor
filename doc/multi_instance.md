
# multi instance flors

An ideal application would sit in a single Ruby process and handle with ease all the work (HTTP requests, background jobs, etc). For an application used by a small to medium team, this might be sufficient.

Often, it's necessary to prepare for growth and split the application on multiple Ruby processes.

The usual flor integrator is building a web application and wants her/his users to take part in workflow executions. Seemingly snappy responses are necessary. One initial technique is to separate HTTP handling from workflow processing, one rocess for each.

Ruby people have developed numerous server libraries for efficient HTTP handling. Some of them ([Passenger](https://www.phusionpassenger.com), [Unicorn](https://bogomips.org/unicorn), ...) manage pools of Ruby processes to distribute the work, when using them, one has to be aware of this.

## separating user interfacing from workflow processing

One could decide to not have flor working in the same Ruby process (or the same group of Ruby processes) as the HTTP handling side. Still access to flor is necessary.

The classical way to do this is to have a "passive" (non-started) flor unit on the HTTP handling side.

A Rails application could thus have an initializer dedicated to a passive flor:
```ruby
#
# config/initializers/flor.rb

FLOR = Flor::Unit.new('../flor/etc/conf.json')
FLOR.conf['unit'] = 'web'
#FLOR.start # no!
```

While the workflow handling side would use an "active" (started) flor unit sharing the same configuration:
```ruby
FLOR = Flor::Unit.new('../flor/etc/conf.json')
FLOR.conf['unit'] = 'flow'
FLOR.start # yes!
```

(Note that I'm using a `FLOR` constant, feel free to use another constant name or another way to point at your flor instance in your Ruby process)

Flow/execution launching/cancelling/signalling thus happens in the web handling side, while the processing happens in its own side.

## extending the workflow processing capacity

TODO

## launching/waiting in a multi instance setup

(already brushed in [launching.md](launching.md))

TODO

