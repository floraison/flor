
# flor quickstart1/

For now, the quickstart just shows how to initialize a flor instance and run a minimal execution in it. The quickstart ends (the Ruby process exits) when the flor execution ends (flor is told to wait for the execution to ends (or fail)).

## running it

```
cd doc/quickstart1/
bundle install
bundle exec ruby quickstart.rb
```

### the outcome

Since `quickstart/flor/etc/conf.json` states `flor_debug: 'stdout,dbg'`, the output of the Ruby program details the messages sent back and forth that make up the runs for the execution that is launched in `quickstart.rb`.

When the execution terminates, when its final run ends, the "terminated" message is pretty-printed. It shows in the payload how "alice" and "bob" each altered the payload by timestamping it.

## the structure

Flor, by default, relies on a flor directory with configuration and tasker implementations.

`etc/` contains the configuration, especially `etc/conf.json`.
`lib/` contains tasker implementations, it could also contain subflows and more.
`var/` where flor writes. In this quickstart the sqlite flor.db file lies there.

```
quickstart1/
├── Gemfile
├── Gemfile.lock
├── README.md
├── flor
│   ├── etc
│   │   └── conf.json
│   ├── lib
│   │   └── taskers
│   │       └── org.example
│   │           ├── alice.rb
│   │           └── bob.rb
│   └── var
│       ├── flor.db
│       └── log
└── quickstart.rb
```

## the flow

The flow simply sits in the `quickstart.rb`, it looks like:

```
concurrence     #
  alice _       # the "workflow definition",
  bob _         # the 'program' that flor interprets
```

It is a vanilla "concurrence", the flow of the execution forking concurrently to "alice" and "bob". Each of these taskers is given a workitem and may alter its payload. Once both replied, the "concurrence" merges the payloads and replies to its parent node. Since "concurrence" is the root node, the execution terminates, with the "terminated" message pretty-printed as the outcome.

## the taskers

Here is "alice":

```ruby
# alice.rb

## tasker implementation

class AliceTasker < Flor::BasicTasker
  def task
    payload['alice_tstamp'] = Time.now.to_s
    reply
  end
end

## tasker configuration

{
  class: 'AliceTasker'
}
```

It sits at `lib/taskers/org.example/alice.rb`. The Ruby file ends with a Hash instance pointing to the Tasker class defined just above.

"alice" simply reacts on tasks, adds her timestamp to the payload and then calls `reply`. That generates a return message for the flor scheduler and lets the execution go on (well once the "concurrence" has done its merging).

