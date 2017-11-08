
# every

"every" is a macro procedure.

```
every 'day at midnight'
  task 'alpha'
```

is automatically turned into:

```
schedule every: 'day at midnight'
  def msg
    task 'alpha'
```

## time strings

Every understands time durations and, somehow, frequencies.

```
every: "5m10s"
every: "5 minutes and 10 seconds"
```

Fugit translates `every: 'day at five'` into `cron: '0 5 * * *'`.

```
every: 'day at five'                  # ==> '0 5 * * *'
every: 'weekday at five'              # ==> '0 5 * * 1,2,3,4,5'
every: 'day at 5 pm'                  # ==> '0 17 * * *'
every: 'tuesday at 5 pm'              # ==> '0 17 * * 2'
every: 'wed at 5 pm'                  # ==> '0 17 * * 3'
every: 'day at 16:30'                 # ==> '30 16 * * *'
every: 'day at noon'                  # ==> '0 12 * * *'
every: 'day at midnight'              # ==> '0 0 * * *'
every: 'tuesday and monday at 5pm'    # ==> '0 17 * * 1,2'
every: 'wed or Monday at 5pm and 11'  # ==> '0 11,17 * * 1,3'
```

## see also

[Cron](cron.md), at, in, [every](every.md), and [sleep](sleep.md).


* [source](https://github.com/floraison/flor/tree/master/lib/flor/punit/every.rb)
* [every spec](https://github.com/floraison/flor/tree/master/spec/punit/every_spec.rb)

