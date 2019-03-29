
# flor quickstart/

For now, the quickstart just shows how to initialize a flor instance and run a minimal execution in it. The quickstart ends (the Ruby process exits) when the flor execution ends (flor is told to wait for the execution to ends (or fail)).

## running it

```
cd quickstart/
bundle install
bundle exec ruby quickstart.rb
```

## the structure

Flor, by default, relies on a flor directory with configuration and tasker implementations.

`etc/` contains the configuration, especially `etc/conf.json`.
`lib/` contains tasker implementations, it could also contain subflows and more.
`var/` where flor writes. In this quickstart the sqlite flor.db file lies there.

```
quickstart/
├── Gemfile
├── Gemfile.lock
├── README.md
├── flor
│   ├── etc
│   │   └── conf.json
│   ├── lib
│   │   └── taskers
│   │       └── org.example
│   │           ├── alice
│   │           │   ├── dot.json
│   │           │   └── tasker.rb
│   │           └── bob
│   │               ├── dot.json
│   │               └── tasker.rb
│   └── var
│       ├── flor.db
│       └── log
└── quickstart.rb
```

