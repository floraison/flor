
# del, delf

Removes a field or a variable.

```
sequence
  del f.a  # blanks field 'a' from the payload
  del a    # blanks variable 'a'
```

Returns the value held in the field or variable or `null` else.

`del` will raise an error if the target field cannot be reached,
but `delf` will not raise and simply return `null`.


* [source](https://github.com/floraison/flor/tree/master/lib/flor/pcore/del.rb)
* [del spec](https://github.com/floraison/flor/tree/master/spec/pcore/del_spec.rb)

