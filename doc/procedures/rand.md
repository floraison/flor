
# rand

Returns a randomly generated number.

```
rand 10        # returns an integer i, 0 <= i < 10
rand 10.0      # returns a float f, 0.0 <= f < 10.0
rand 1 11      # returns an integer i, 1 <= i < 11
rand 1.0 11    # returns a float f, 1.0 <= f < 11.0
rand 1 11.0    # returns a float f, 1.0 <= f < 11.0
rand 1.0 11.0  # returns a float f, 1.0 <= f < 11.0
```

When give no argument, it simply takes the current `payload['ret']`
```
sequence
  10
  rand  # returns an integer i, 0 <= i < 10
```


* [source](https://github.com/floraison/flor/tree/master/lib/flor/pcore/rand.rb)
* [rand spec](https://github.com/floraison/flor/tree/master/spec/pcore/rand_spec.rb)

