
# blocks

Ruby has blocks, flor is closer to Javascript, it needs functions.

Blocks are nicer, especially for non-programmers. Non-programmers will probably have a look at the flows. Blocks might help.


## schedule and its macros

```
schedule  #### needs function

  cron      #
  every     #
  at        #
  in        ## accepts blocks, transforms into "schedule"
```

```
cron '0 0 1 jan *'
  task albert 'take out garbage'
```
is turned into:
```
schedule cron: '0 0 1 jan *'
  def msg
    task albert 'take out garbage'
```


## trap and on

```
on 'approve'
  task 'bob' mission: 'gather signatures'
```
is turned into:
```
trap point: 'signal', name: 'approve'
  set sig 'signal'
  def msg
    task 'bob' mission: 'gather signatures'
```

"on" traps signal.


## map and co

Use the `ect` procedure for the "block" versions. Use the FP "classical" name for the "func" versions.

```
block     block           func          Ruby and others
-------------------------------------------------------
collect   do-map          map
select    do-filter       filter        find_all
reject    do-filter-out   filter-out    delete_if
inject    do-reduce       reduce        reduce
                                        foldr
detect                    find          detect, find
                          any
                          every         all?
each                      for-each      each
```

