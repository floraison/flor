
# apply

Applies a function.

```
sequence
  define sum a b
    +
      a
      b
  apply sum 1 2
```

It is usually used implicitly, as in
```
sequence
  define sum a b
    +
      a
      b
  sum 1 2
```
where flor figures out by itself it has to use this "apply" procedure
to call the function.

## rubyesque blocks

In Ruby, one case pass a block on a function call:
```ruby
def f(i)
  i * yield
end
p f(5) { |j| 10 }
```
which just prints `50`.

This can be achieved in flor like this:
```
define f i
  * i (yield _)
f 5
  10
echo f.ret
```

If one needs to have a "block" with parameters, it can be done by having
an anonymous function definition has the only thing in the block:
```
define f i
  + i (yield i)
f 5
  def j
    * 3 j
f.ret #=> 20
```

## see also

[define](define.md).


* [source](https://github.com/floraison/flor/tree/master/lib/flor/pcore/apply.rb)
* [apply spec](https://github.com/floraison/flor/tree/master/spec/pcore/apply_spec.rb)

