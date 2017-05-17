
# case

The classical case form.

Takes a 'key' and then look at arrays until it finds one that contains
the key. When found, it executes the child immediately following the
winning array.

```
case level
  [ 0 1 2 ]; 'low'
  [ 3 4 5 ]; 'medium'
  else; 'high'
```
which is a ";"ed version of
```
case level
  [ 0 1 2 ]
  'low'
  [ 3 4 5 ]
  'medium'
  else
  'high'
```

## else

As seen in the example above, an "else" in lieu of an array acts as
a catchall and the child immediately following it is executed.

If there is no else and no matching array, the case terminates and
doesn't set the field "ret".


* [source](https://github.com/floraison/flor/tree/master/lib/flor/pcore/case.rb)
* [case spec](https://github.com/floraison/flor/tree/master/spec/pcore/case_spec.rb)

