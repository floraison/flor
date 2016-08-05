
<!--
# specifying flor
#
# Mon Mar  7 06:24:41 JST 2016
-->

## atoms

```flon
  1
```
parses to
```ruby
  [ '_num', 1, 1 ]
```
---

```flon
  11.01
```
parses to
```ruby
  [ '_num', 11.01, 1 ]
```
---

```flon
  true
```
parses to
```ruby
  [ '_boo', true, 1 ]
```
---

```flon
  false
```
parses to
```ruby
  [ '_boo', false, 1 ]
```
---

```flon
  null
```
parses to
```ruby
  [ '_nul', nil, 1 ]
```
---

```flon
  abc
```
parses to
```ruby
  [ 'abc', [], 1 ]
```
---

```flon
  'def'
```
parses to
```ruby
  [ '_sqs', 'def', 1 ]
```
---

```flon
  "ghi"
```
parses to
```ruby
  [ '_dqs', 'ghi', 1 ]
```
---

```flon
  /jkl/
```
parses to
```ruby
  [ '_rxs', '/jkl/', 1 ]
```
---

```flon
  /jkl/i
```
parses to
```ruby
  [ '_rxs', '/jkl/i', 1 ]
```
---

```flon
  /jkl\/3/i
```
parses to
```ruby
  [ '_rxs', '/jkl\/3/i', 1 ]
```
---

```flon
  /jkl/i / 1
```
parses to
```ruby
  [ '/', [
    [ '_rxs', '/jkl/i', 1 ],
    [ '_num', 1, 1 ]
  ], 1 ]
```
---

## arrays

```flon
  []
```
parses to
```ruby
  [ '_arr', 0, 1 ]
```
---

```flon
  [ 1, 2, 3 ]
```
parses to
```ruby
  [ '_arr', [
    [ '_num', 1, 1 ], [ '_num', 2, 1 ], [ '_num', 3, 1 ]
  ], 1 ]
```
---

```flon
  [ 1 2 3 ]
```
parses to
```ruby
  [ '_arr', [
    [ '_num', 1, 1 ], [ '_num', 2, 1 ], [ '_num', 3, 1 ]
  ], 1 ]
```
---

```flon
  [1 2
  3]
```
parses to
```ruby
  [ '_arr', [
    [ '_num', 1, 1 ], [ '_num', 2, 1 ], [ '_num', 3, 2 ]
  ], 1 ]
```

## objects

```flon
  {}
```
parses to
```ruby
  [ '_obj', 0, 1 ]
```
---

```flon
  { a: A, b: 2, c: true }
```
parses to
```ruby
  [ '_obj', [
    [ 'a', [], 1 ], [ 'A', [], 1 ],
    [ 'b', [], 1 ], [ '_num', 2, 1 ],
    [ 'c', [], 1 ], [ '_boo', true, 1 ]
  ], 1 ]
```
---

```flon
  { a: A b: 2 c: true }
```
parses to
```ruby
  [ '_obj', [
    [ 'a', [], 1 ], [ 'A', [], 1 ],
    [ 'b', [], 1 ], [ '_num', 2, 1 ],
    [ 'c', [], 1 ], [ '_boo', true, 1 ]
  ], 1 ]
```
---

```flon
  { a: A # ah ah ah
    b: 2 c: # oh oh oh
      true }
```
parses to
```ruby
  [ '_obj', [
    [ 'a', [], 1 ], [ 'A', [], 1 ],
    [ 'b', [], 2 ], [ '_num', 2, 2 ],
    [ 'c', [], 2 ], [ '_boo', true, 3 ]
  ], 1 ]
```

## operations

```flon
  10 + 11 - 5
```
parses to
```ruby
  [ '-', [
    [ '+', [
      [ '_num', 10, 1 ],
      [ '_num', 11, 1 ]
    ], 1 ],
    [ '_num', 5, 1 ]
  ], 1 ]
```
---

```flon
  1 + 1 * 2
```
parses to
```ruby
  [ '+', [
    [ '_num', 1, 1 ],
    [ '*', [
      [ '_num', 1, 1 ],
      [ '_num', 2, 1 ]
    ], 1 ]
  ], 1 ]
```
---

```flon
  + 10 11 12
```
parses to
```ruby
  [ '+', [
    [ '_num', 10, 1 ],
    [ '_num', 11, 1 ],
    [ '_num', 12, 1 ]
  ], 1 ]
```
---

```flon
  +
    10
    11
    12
```
parses to
```ruby
  [ '+', [
    [ '_num', 10, 2 ],
    [ '_num', 11, 3 ],
    [ '_num', 12, 4 ]
  ], 1 ]
```
---

```flon
  (+ 10 11 12)
```
parses to
```ruby
  [ '+', [
    [ '_num', 10, 1 ],
    [ '_num', 11, 1 ],
    [ '_num', 12, 1 ]
  ], 1 ]
```
---

```flon
  (10 + 11 + 12)
```
parses to
```ruby
  [ '+', [
    [ '_num', 10, 1 ],
    [ '_num', 11, 1 ],
    [ '_num', 12, 1 ]
  ], 1 ]
```
---

```flon
  10 -5
```
parses to
```ruby
  [ '+', [
    [ '_num', 10, 1 ],
    [ '_num', -5, 1 ]
  ], 1 ]
```
---

```flon
  10 + -5
```
parses to
```ruby
  [ '+', [
    [ '_num', 10, 1 ],
    [ '_num', -5, 1 ],
  ], 1 ]
```
---

```flon
  + 10 5
```
parses to
```ruby
  [ '+', [
    [ '_num', 10, 1 ],
    [ '_num', 5, 1 ],
  ], 1 ]
```
---

```flon
  - 10 -5
```
parses to
```ruby
  [ '-', [
    [ '_num', 10, 1 ],
    [ '_num', -5, 1 ],
  ], 1 ]
```

## lines

```flon
  sequence
```
parses to
```ruby
  [ 'sequence', [], 1 ]
```
---

```flon
  sequence
    a
    b
```
parses to
```ruby
  [ 'sequence', [
    [ 'a', [], 2 ],
    [ 'b', [], 3 ]
  ], 1 ]
```
---

```flon
  sequence a b
```
parses to
```ruby
  [ 'sequence', [
    [ '_att', [ [ 'a', [], 1 ] ], 1 ],
    [ '_att', [ [ 'b', [], 1 ] ], 1 ]
  ], 1 ]
```
---

```flon
  sequence a, vars: 1, timeout: 1h, b
```
parses to
```ruby
  [ 'sequence', [
    [ '_att', [ [ 'a', [], 1 ] ], 1 ],
    [ '_att', [ [ 'vars', [], 1 ], [ '_num', 1, 1 ], ], 1 ],
    [ '_att', [ [ 'timeout', [], 1 ], [ '1h', [], 1 ], ], 1 ],
    [ '_att', [ [ 'b', [], 1 ] ], 1 ]
  ], 1 ]
```
---

```flon
  sequence a: 1 + 1, 2
```
parses to
```ruby
  [ 'sequence', [
    [ '_att', [
      [ 'a', [], 1 ],
      [ '+', [
        [ '_num', 1, 1 ],
        [ '_num', 1, 1 ]
      ], 1 ],
    ], 1 ],
    [ '_att', [
      [ '_num', 2, 1 ]
    ], 1 ]
  ], 1 ]
```
---

```flon
  sequence
    define sum a b
      +
        a
        b
    apply sum 1 2
```
parses to
```ruby
  [ 'sequence', [
    [ 'define', [
      [ '_att', [ [ 'sum', [], 2 ], ], 2 ],
      [ '_att', [ [ 'a', [], 2 ], ], 2 ],
      [ '_att', [ [ 'b', [], 2 ], ], 2 ],
      [ '+', [ [ 'a', [], 4 ], [ 'b', [], 5 ] ], 3 ]
    ], 2 ],
    [ 'apply', [
      [ '_att', [ [ 'sum', [], 6 ], ], 6 ],
      [ '_att', [ [ '_num', 1, 6 ], ], 6 ],
      [ '_att', [ [ '_num', 2, 6 ], ], 6 ]
    ], 6 ]
  ], 1 ]
```
---

```flon
  sequence vars: {}
    task nada, cc: []
```
parses to
```ruby
  [ 'sequence', [
    [ '_att', [ [ 'vars', [], 1 ], [ '_obj', 0, 1 ] ], 1 ],
    [ 'task', [
      [ '_att', [ [ 'nada', [], 2 ] ], 2 ],
      [ '_att', [ [ 'cc', [], 2 ], [ '_arr', 0, 2 ] ], 2 ]
    ], 2 ]
  ], 1 ]
```

## lines with regexes

```flon
  match v.a /hello world/
```
parses to
```ruby
  [ 'match', [
    [ '_att', [ [ '/', [ ['v.a', [], 1 ], [ 'hello', [], 1 ] ], 1 ] ], 1 ],
    [ '_att', [ [ 'world/', [], 1 ] ], 1 ]
  ], 1 ]
```
---

```flon
  match v.a, /hello world/
```
parses to
```ruby
  [ 'match', [
    [ '_att', [ [ 'v.a', [], 1 ] ], 1 ],
    [ '_att', [ [ '_rxs', '/hello world/', 1 ] ], 1 ],
  ], 1 ]
```
---

(pending)
```flon
  hello /world/
```
parses to
```ruby
  [ 'hello', [ [ '_att', [ [ '_rxs', '/world/', 1 ] ], 1 ], ], 1 ]
```
---

```flon
  hello, /world/
```
parses to
```ruby
  [ 'hello', [ [ '_att', [ [ '_rxs', '/world/', 1 ] ], 1 ], ], 1 ]
```
---

```flon
  /hello/ / 'world'
```
parses to
```ruby
  [ '/', [
    [ '_rxs', "/hello/", 1 ],
    [ '_sqs', 'world', 1 ]
  ], 1 ]
```

## comments

```flon
  sequence # long time
    a
    b # no see
```
parses to
```ruby
  [ 'sequence', [
    [ 'a', [], 2 ],
    [ 'b', [], 3 ]
  ], 1 ]
```
---

```flon
  sequence # slash slash
    a
    b # baby
```
parses to
```ruby
  [ 'sequence', [
    [ 'a', [], 2 ],
    [ 'b', [], 3 ]
  ], 1 ]
```
---

## line breaks

```flon
  [ 1, 2 # trois
    4 ]
```
parses to
```ruby
  [ '_arr', [
    [ '_num', 1, 1 ], [ '_num', 2, 1 ], [ '_num', 4, 2 ]
  ], 1 ]
```
---

```flon
  [ 1, 2, # trois
    4 ]
```
parses to
```ruby
  [ '_arr', [
    [ '_num', 1, 1 ], [ '_num', 2, 1 ], [ '_num', 4, 2 ]
  ], 1 ]
```
---

```flon
  [ 1,
  
  2,
\
    4 ]
```
parses to
```ruby
  [ '_arr', [
    [ '_num', 1, 1 ], [ '_num', 2, 3 ], [ '_num', 4, 5 ]
  ], 1 ]
```

---

```flon
  { a: "anthracite" # comment
    b: "blue-yellow" cc: "carmin"
  }
```
parses to
```ruby
  [ '_obj', [
    [ 'a', [], 1 ], [ '_dqs', 'anthracite', 1 ],
    [ 'b', [], 2 ], [ '_dqs', 'blue-yellow', 2 ],
    [ 'cc', [], 2 ], [ '_dqs', 'carmin', 2 ],
  ], 1 ]
```
---

```flon
  sequence a, b, [ 1 # in the middle
    2], c
```
parses to
```ruby
  [ 'sequence', [
    [ '_att', [ [ 'a', [], 1 ] ], 1 ],
    [ '_att', [ [ 'b', [], 1 ] ], 1 ],
    [ '_att', [ [ '_arr', [ [ '_num', 1, 1 ], [ '_num', 2, 2 ] ], 1 ], ], 1 ],
    [ '_att', [ [ 'c', [], 2 ] ], 2 ]
  ], 1 ]
```
---

```flon
  sequence a, b, [ 1
    2], c
```
parses to
```ruby
  [ 'sequence', [
    [ '_att', [ [ 'a', [], 1 ] ], 1 ],
    [ '_att', [ [ 'b', [], 1 ] ], 1 ],
    [ '_att', [ [ '_arr', [ [ '_num', 1, 1 ], [ '_num', 2, 2 ] ], 1 ], ], 1 ],
    [ '_att', [ [ 'c', [], 2 ] ], 2 ]
  ], 1 ]
```
---

```flon
  sequence a, b, [ 1 \
    2], c
```
parses to
```ruby
  [ 'sequence', [
    [ '_att', [ [ 'a', [], 1 ] ], 1 ],
    [ '_att', [ [ 'b', [], 1 ] ], 1 ],
    [ '_att', [ [ '_arr', [ [ '_num', 1, 1 ], [ '_num', 2, 2 ] ], 1 ], ], 1 ],
    [ '_att', [ [ 'c', [], 2 ] ], 2 ]
  ], 1 ]
```
---

```flon
  sequence a, b,
    c
```
parses to
```ruby
  [ 'sequence', [
    [ '_att', [ [ 'a', [], 1 ] ], 1 ],
    [ '_att', [ [ 'b', [], 1 ] ], 1 ],
    [ '_att', [ [ 'c', [], 2 ] ], 2 ]
  ], 1 ]
```
---

```flon
  map \
    [ 1, 2 ]
    fun
```
parses to
```ruby
  [ 'map', [
    [ '_att', [ [ '_arr', [ [ '_num', 1, 2 ], [ '_num', 2, 2 ] ], 2 ] ], 2 ],
    [ 'fun', [], 3 ]
  ], 1 ]
```
---

## parentheses

```flon
  sequence timeout: (+ 7 8 "h")
    a
    b
```
parses to
```ruby
  [ 'sequence', [
    [ '_att', [
      [ 'timeout', [], 1 ],
      [ '+', [
        [ '_num', 7, 1 ],
        [ '_num', 8, 1 ],
        [ '_dqs', 'h', 1 ]
      ], 1 ],
    ], 1 ],
    [ 'a', [], 2 ],
    [ 'b', [], 3 ]
  ], 1 ]
```
---

## dollar

```flon
  sequence
    f.a
    "$(f.a)"
    "$(f.a)-$(f.b)" 1
```
parses to
```ruby
  [ 'sequence', [
    [ 'f.a', [], 2 ],
    [ '_dqs', '$(f.a)', 3 ],
    [ [ '_dqs', '$(f.a)-$(f.b)', 4 ], [
      [ '_att', [
        [ '_num', 1, 4 ]
      ], 4 ]
    ], 4 ]
  ], 1 ]
```
---

## semicolon

```flon
  map [ 1, 2 ]; def x; + 1 x
```
parses to
```ruby
  [ 'map', [
    [ '_att', [ [ '_arr', [ [ '_num', 1, 1 ], [ '_num', 2, 1 ] ], 1 ] ], 1 ],
    [ 'def', [
      [ '_att', [ [ 'x', [], 1 ] ], 1 ],
      [ '+', [
        [ '_num', 1, 1 ],
        [ 'x', [], 1 ]
      ], 1 ]
    ], 1 ]
  ], 1 ]
```
---

```flon
  sequence; a;; b;; c
```
parses to
```ruby
  [ 'sequence', [
    [ 'a', [], 1 ], [ 'b', [], 1 ], [ 'c', [], 1 ]
  ], 1 ]
```
---

```flon
  sequence
;a
    b;; c
```
parses to
```ruby
  [ 'sequence', [
    [ 'a', [], 2 ], [ 'b', [], 3 ], [ 'c', [], 3 ]
  ], 1 ]
```
---

```flon
  sequence; a | b | c
```
parses to
```ruby
  [ 'sequence', [
    [ 'a', [], 1 ], [ 'b', [], 1 ], [ 'c', [], 1 ]
  ], 1 ]
```


## suffix if and unless

```flon
  push 7 if a > b
```
parses to
```ruby
  [ 'ife', [
    [ '>', [ [ 'a', [], 1 ], [ 'b', [], 1 ] ], 1 ],
    [ 'push', [ [ '_att', [ [ '_num', 7, 1 ] ], 1 ] ], 1 ]
  ], 1 ]
```
---

```flon
  push 8 unless a > b
```
parses to
```ruby
  [ 'unlesse', [
    [ '>', [ [ 'a', [], 1 ], [ 'b', [], 1 ] ], 1 ],
    [ 'push', [ [ '_att', [ [ '_num', 8, 1 ] ], 1 ] ], 1 ]
  ], 1 ]
```
---

```flon
  #a > b timeout: "3d"
  > a b timeout: "3d"
```
parses to
```ruby
  [">",
   [["_att", [["a", [], 2]], 2],
    ["_att", [["b", [], 2]], 2],
    ["_att", [["timeout", [], 2], ["_dqs", "3d", 2]], 2]],
   2]
```


## misc

```flon
  { sto_uri: (ife; true | 10 | 11) a: 1 }
```
parses to
```ruby
  [ '_obj', [
    [ 'sto_uri', [], 1 ],
    [ 'ife', [
      [ '_boo', true, 1 ], [ '_num', 10, 1 ], [ '_num', 11, 1 ]
    ], 1 ],
    [ 'a', [], 1 ],
    [ '_num', 1, 1 ]
  ], 1 ]
```
---

```flon
  { sto_uri: (
    ife
      true
      10
      11) a: 1 }
```
parses to
```ruby
  [ '_obj', [
    [ 'sto_uri', [], 1 ],
    [ 'ife', [
      [ '_boo', true, 3 ], [ '_num', 10, 4 ], [ '_num', 11, 5 ]
    ], 2 ],
    [ 'a', [], 5 ],
    [ '_num', 1, 5 ]
  ], 1 ]
```

---

```flon
  set f.d { a: 0 }
```
parses to
```ruby
  [ 'set', [
    [ '_att', [
      [ 'f.d', [], 1 ]
    ], 1 ],
    [ '_att', [
      [ '_obj', [
        [ 'a', [], 1 ], [ '_num', 0, 1 ]
      ], 1 ]
    ], 1 ]
  ], 1 ]
```
