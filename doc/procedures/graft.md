
# graft, import

Graft a subtree into the current flo

Given
```
# sub0.flo
sequence
  task 'a'
  task 'b'
```
and
```
# sub1.flo
sequence
  task 'c'
  task 'd'
```
then
```
# main.flo
concurrence
  graft 'sub0.flo'
  graft 'sub1' # suffix can be omitted
  graft 'sub0'
    #
    # which is thus equivalent to
    #
concurrence
  sequence
    task 'a'
    task 'b'
  sequence
    task 'c'
    task 'd'
  sequence
    task 'a'
    task 'b'
```


* [source](https://github.com/floraison/flor/tree/master/lib/flor/punit/graft.rb)
* [graft spec](https://github.com/floraison/flor/tree/master/spec/punit/graft_spec.rb)

