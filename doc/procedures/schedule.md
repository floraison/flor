
# schedule

Schedules a function

```
schedule cron: '0 0 1 jan *'  # every 1st day of the year, check systems
  def msg
    check_systems
```

See also: cron, at, in and sleep


* [source](https://github.com/floraison/flor/tree/master/lib/flor/punit/schedule.rb)
* [schedule spec](https://github.com/floraison/flor/tree/master/spec/punit/schedule_spec.rb)

