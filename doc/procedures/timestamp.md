
# timestamp, ltimestamp

Places a string timestamp in f.ret.

## timestamp

Places the current UTC timestamp into `f.ret`.

```
set f.timestamp  # set the field "timestamp" to
  timestamp _    # something like "2018-08-13T08:04:06Z"
```

## ltimestamp

```
set f.timestamp  # set the field "timestamp" to
  ltimestamp _    # something like "2018-08-13T10:04:06"
```


* [source](https://github.com/floraison/flor/tree/master/lib/flor/pcore/timestamp.rb)
* [timestamp spec](https://github.com/floraison/flor/tree/master/spec/pcore/timestamp_spec.rb)

