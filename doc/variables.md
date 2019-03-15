
# variables

Flor has a payload of fields transiting in its workitems, but it also has variables. They stay in the execution, they are not passed to taskers (unless their configurations sport `include_vars: true`).

Variables are thus mostly to help for the control flow.

## variable categories

By default, variables are local. The trees of executions may have variable containers, scopes, at any node.

```
sequence                                              # '0' root scope, where
                                                      # global variable are
  set content 'conquer wessex'

  define request_work name content                    # function calls get their
    email worker_name "please work on $(content)"     # own scope
    task name content                                 #

  concurrence
    request_work 'alfred' content
    request_work 'bill' 'conquer england'

  sequence vars: { content: 'conquer anglia' }        # new scope
    request_work 'aethelred' gv.content               # ref to global var
```

There are also [domain variables](#domain-variables), shared by all the executions in a domain and its subdomains.

### local variables

TODO

### global variables

TODO

### domain variables

TODO

### pseudo variables

TODO

## variable black/white listing

TODO

## passing variables to taskers

TODO

## ways of starting new variable scopes

TODO

## closures

TODO

