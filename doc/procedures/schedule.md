
# schedule

Schedules a function

```
schedule cron: '0 0 1 jan *'  # every 1st day of the year, check systems
  def msg
    check_systems
```

It understands `cron:`, `at:`, `in:`, and `every:`.

The time string parsing is done by the
[fugit](https://github.com/floraison/fugit) gem.

## every:

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

Cron, at, in, every, and [sleep](sleep.md).


* [source](https://github.com/floraison/flor/tree/master/lib/flor/punit/schedule.rb)
* [schedule spec](https://github.com/floraison/flor/tree/master/spec/punit/schedule_spec.rb)

