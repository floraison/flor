
# loader service

A flor unit uses a loader to get

* workflow definitions (`.flo` or `.flor`)
* execution variables (variables set at the start of an execution in the root node)
* taskers (usually invoked via a `task` procedure or directly by their name)
* hooks (pieces of code run on specific messages)

## loader "filesystem"

The default loader implementation shipping in flor loads its ware from a tree of files inspired from the UNIX file system.

Here is an example tree:
```
.
├── etc
│   ├── conf.json
│   └── variables
│       ├── com.example
│       │   └── dot.json   # variables for com/example and below exes
│       └── dot.json       # variables for any exe
├── lib
│   ├── flows
│   │   ├── com.example
│   │   │   └── billing.flo
│   │   └── com.example.accounting
│   │       └── yearclosure.flo
│   ├── hooks
│   └── taskers
│       ├── com.example
│       │   ├── team_a         # the com/example/team_a tasker
│       │   │   ├── dot.json
│       │   │   └── tasker.rb
│       │   └── team_b         # the com/example/team_b tasker
│       │       ├── dot.json
│       │       └── tasker.rb
│       └── com.example.accounting.json   # taskers for com/example/accouting
├── usr
│   └── com.example.sales
│       └── co
│           ├── etc
│           │   └── variables.json        # vars for com/example/sales
│           └── lib
│               ├── flows
│               │   └── onboarding.flo    # com/examples/sales/onboarding.flo
│               └── taskers
│                   ├── customer.json     #
│                   ├── sales.json        #
│                   └── sales_head.json   # taskers for com/example/sales/
└── var
```

The loader looks at all the file in its tree and builds an expanded structure, where dots and slashes are equivalent. For example `com.example/sales` and `com.example.sales` are equivalent. Dots allow for a less deep tree hierarchy on disk.

### json flavour

TODO


## links

* [source](https://github.com/floraison/flor/tree/master/lib/flor/unit/loader.rb)
* [spec](https://github.com/floraison/flor/tree/master/spec/unit/loader_spec.rb)

