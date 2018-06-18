
<!--
# specifying flor
#
# Mon Mar  7 06:24:41 JST 2016
-->

## atoms

```flor
  1
```
parses to
```ruby
  [ '_num', 1, 1 ]
```
---

```flor
  11.01
```
parses to
```ruby
  [ '_num', 11.01, 1 ]
```
---

```flor
  true
```
parses to
```ruby
  [ '_boo', true, 1 ]
```
---

```flor
  false
```
parses to
```ruby
  [ '_boo', false, 1 ]
```
---

```flor
  null
```
parses to
```ruby
  [ '_nul', nil, 1 ]
```
---

### symbols

```flor
  abc
```
parses to
```ruby
  [ 'abc', [], 1 ]
```
---

### single quoted strings

```flor
  'def'
```
parses to
```ruby
  [ '_sqs', 'def', 1 ]
```
---

```flor
  '\u5929\u6C17'
```
parses to
```ruby
  [ '_sqs', '天気', 1 ]
```
---

```flor
  'don\'t think "food"'
```
parses to
```ruby
  [ '_sqs', "don't think \"food\"", 1 ]
```
---

### double quoted strings

```flor
  "ghi"
```
parses to
```ruby
  [ '_dqs', 'ghi', 1 ]
```
---

```flor
  "0\"1\\2\/3\b4\f5\n6\r7\t8"
```
parses to
```ruby
  [ '_dqs', "0\"1\\2\/3\b4\f5\n6\r7\t8", 1 ]
```
---

```flor
  "0\"1\\2\\/3\\b4\\f5\\n6\\r7\\t8"
```
parses to
```ruby
  [ '_dqs', "0\"1\\2\\/3\\b4\\f5\\n6\\r7\\t8", 1 ]
```
---

```flor
  "おはようございます、ええ天気ですねー"
```
parses to
```ruby
  [ '_dqs', "おはようございます、ええ天気ですねー", 1 ]
```
---

```flor
  "\u5929\u6C17"
```
parses to
```ruby
  [ '_dqs', "天気", 1 ]
```
---

```flor
  "don't think \"food\""
```
parses to
```ruby
  [ '_dqs', "don't think \"food\"", 1 ]
```
---

```flor
  set "f.h[\"pullover\"]" 'blue'
```
parses to
```ruby
  [ 'set',
    [ [ '_att', [ [ "_dqs", "f.h[\"pullover\"]", 1 ] ], 1 ],
      [ '_att', [ [ "_sqs", "blue", 1 ] ], 1 ] ],
    1 ]
```
---

### regular expressions

```flor
  /jkl/
```
parses to
```ruby
  [ '_rxs', '/jkl/', 1 ]
```
---

```flor
  /jkl/i
```
parses to
```ruby
  [ '_rxs', '/jkl/i', 1 ]
```
---

```flor
  /jkl\/3/i
```
parses to
```ruby
  [ '_rxs', '/jkl\/3/i', 1 ]
```
---

```flor
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

```flor
  /^$\A\Z\z\G\b\Bmno/
```
parses to
```ruby
  [ '_rxs', '/^$\A\Z\z\G\b\Bmno/', 1 ]
```
---

```flor
  /\u5929\u6C17/
```
parses to
```ruby
  [ '_rxs', '/\u5929\u6C17/', 1 ]
```
---

```flor
  [ /bl/ 'red' ]
```
parses to
```ruby
  [ '_arr', [ [ '_rxs', '/bl/', 1 ], [ '_sqs', 'red', 1 ] ], 1 ]
```
---

```flor
  [ 'red', /bl/ ]
```
parses to
```ruby
  [ '_arr', [ [ '_sqs', 'red', 1 ], [ '_rxs', '/bl/', 1 ] ], 1 ]
```
---

(pending)
```flor
  [ 'red' /bl/ ]
```
parses to
```ruby
  [ '_arr', [ [ '_sqs', 'red', 1 ], [ '_rxs', '/bl/', 1 ] ], 1 ]
```
---

```flor
  [ 'red' (/bl/) ]
```
parses to
```ruby
  [ '_arr', [ [ '_sqs', 'red', 1 ], [ '_rxs', '/bl/', 1 ] ], 1 ]
```
---

### references

```flor
  f.a
```
parses to
```ruby
  [ 'f.a', [] , 1 ]
```
---

```flor
  f.a.1
```
parses to
```ruby
  [ 'f.a.1', [] , 1 ]
```
---

```flor
  f.a.first[1]['hair']["colour"]
```
parses to
```ruby
  [ "f.a.first[1]['hair'][\"colour\"]", [], 1 ]
```
---

```flor
  f.a.first[1,3].name
```
parses to
```ruby
  [ "f.a.first[1,3].name", [], 1 ]
```
---

```flor
  f.a.first[1:7]
```
parses to
```ruby
  [ "f.a.first[1:7]", [], 1 ]
```
---

```flor
  f.a.first[1:3:4]
```
parses to
```ruby
  [ "f.a.first[1:3:4]", [], 1 ]
```
---

(pending)
```flor
  f.a.first[1 :3 : 4 ]
```
parses to
```ruby
  [ "f.a.first[1:3:4]", [], 1 ]
```
---

## arrays

```flor
  []
```
parses to
```ruby
  [ '_arr', [
    [ '_att', [
      [ '_', [], 1 ]
    ], 1 ]
  ], 1 ]
```
---

```flor
  [ 1, 2, 3 ]
```
parses to
```ruby
  [ '_arr', [
    [ '_num', 1, 1 ], [ '_num', 2, 1 ], [ '_num', 3, 1 ]
  ], 1 ]
```
---

```flor
  [ 1 2 3 ]
```
parses to
```ruby
  [ '_arr', [
    [ '_num', 1, 1 ], [ '_num', 2, 1 ], [ '_num', 3, 1 ]
  ], 1 ]
```
---

```flor
  [1 2
  3]
```
parses to
```ruby
  [ '_arr', [
    [ '_num', 1, 1 ], [ '_num', 2, 1 ], [ '_num', 3, 2 ]
  ], 1 ]
```
---

```flor
  [ (sleep '3h') 2 3 ] timeout: '2h'
```
parses to
```ruby
  [ '_arr',
    [ [ '_att', [ [ 'timeout', [], 1 ], [ '_sqs', '2h', 1 ] ], 1 ],
    [ 'sleep', [ [ '_att', [ [ '_sqs', '3h', 1 ] ], 1 ] ], 1 ],
    [ '_num', 2, 1 ],
    [ '_num', 3, 1 ] ],
    1 ]
```


## objects

```flor
  {}
```
parses to
```ruby
  [ '_obj', [
    [ '_att', [
      [ '_', [] ,1 ]
    ], 1 ]
  ], 1 ]
```
---

```flor
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

```flor
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

```flor
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
---

```flor
  { a: 1, b: 2 } timeout: '2h'
```
parses to
```ruby
  [ '_obj', [
    [ '_att', [ [ 'timeout', [], 1 ], [ '_sqs', '2h', 1 ] ], 1 ],
    [ 'a', [], 1 ], [ '_num', 1, 1 ],
    [ 'b', [], 1 ], [ '_num', 2, 1 ]
  ], 1 ]
```
---

```flor
  { a: 1, b: 2 } timeout: '2h' if c > 1
```
parses to
```ruby
  [ 'if', [
    [ '>', [ [ 'c', [], 1 ], [ '_num', 1, 1 ] ], 1 ],
    [ '_obj', [
      [ '_att', [ [ 'timeout', [], 1 ], [ '_sqs', '2h', 1 ] ], 1 ],
      [ 'a', [], 1 ], [ '_num', 1, 1 ],
      [ 'b', [], 1 ], [ '_num', 2, 1 ]
    ], 1 ]
  ], 1 ]
```

## arithmetical operations

```flor
  -10
```
parses to
```ruby
  [ '_num', -10, 1 ]
```
---

```flor
  - 10
```
parses to
```ruby
  [ '_num', -10, 1 ]
```
---

```flor
  10 + 11 - 5
```
parses to
```ruby
  [ '+', [
    [ '_num', 10, 1 ],
    [ '_num', 11, 1 ],
    [ '_num', -5, 1 ]
  ], 1 ]
```
---

```flor
  -10 + 11 - 5
```
parses to
```ruby
  [ '+', [
    [ '_num', -10, 1 ],
    [ '_num', 11, 1 ],
    [ '_num', -5, 1 ]
  ], 1 ]
```
---

```flor
  - 10 + 11 - 5
```
parses to
```ruby
  [ '+', [
    [ '_num', -10, 1 ],
    [ '_num', 11, 1 ],
    [ '_num', -5, 1 ]
  ], 1 ]
```
---

```flor
  -
    10
    -11
```
parses to
```ruby
  [ '-', [ [ '_num', 10, 2 ], [ '_num', -11, 3 ] ], 1 ]
```
---

```flor
  1 + 2 * 3
```
parses to
```ruby
  [ '+', [
    [ '_num', 1, 1 ],
    [ '*', [
      [ '_num', 2, 1 ],
      [ '_num', 3, 1 ]
    ], 1 ]
  ], 1 ]
```
---

```flor
  1 * 2 + 3
```
parses to
```ruby
  [ '+', [
    [ '*', [
      [ '_num', 1, 1 ],
      [ '_num', 2, 1 ]
    ], 1 ],
    [ '_num', 3, 1 ]
  ], 1 ]
```
---

```flor
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

```flor
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

```flor
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

```flor
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

```flor
  10 -5
```
parses to
```ruby
  [ '-', [
    [ '_num', 10, 1 ],
    [ '_num', 5, 1 ]
  ], 1 ]
```
---

```flor
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

```flor
  + 10 5
```
parses to
```ruby
  [ '+', [
    [ '_num', 10, 1 ],
    [ '_num', 5, 1 ]
  ], 1 ]
```
---

```flor
  - 10 -5 3
```
parses to
```ruby
  [ '-', [
    [ '-', [
      [ '_num', 10, 1 ],
      [ '_num', 5, 1 ]
    ], 1 ],
    [ '_num', 3, 1 ],
  ], 1 ]
```
---

```flor
  -5 +6 -7
```
parses to
```ruby
  [ '+', [ [ '_num', -5, 1 ], [ '_num', 6, 1 ], [ '_num', -7, 1 ] ], 1 ]
```
---

```flor
  - a -b
```
parses to
```ruby
  [ '-', [
    [ '-', [
      [ 'a', [], 1 ]
    ], 1 ],
    [ 'b', [], 1 ]
  ], 1 ]
```
---

```flor
  11 % 5 * 3
```
parses to
```ruby
  [ '*', [
    [ '%', [
      [ '_num', 11, 1 ],
      [ '_num', 5, 1 ]
    ], 1 ],
    [ '_num', 3, 1 ]
  ], 1 ]
```

## logical operations

```flor
  not a
```
parses to
```ruby
  [ 'not', [
    [ '_att', [
      [ 'a', [], 1 ]
    ], 1 ]
  ], 1 ]
```
---

```flor
  and a b
```
parses to
```ruby
  [ 'and', [
    [ '_att', [ [ 'a', [], 1 ] ], 1 ],
    [ '_att', [ [ 'b', [], 1 ] ], 1 ],
  ], 1 ]
```
---

```flor
  a and b
```
parses to
```ruby
  [ 'and', [
    [ 'a', [], 1 ],
    [ 'b', [], 1 ]
  ], 1 ]
```
---

```flor
  a and b or c
```
parses to
```ruby
  [ 'or', [
    [ 'and', [
      [ 'a', [], 1 ],
      [ 'b', [], 1 ]
    ], 1 ],
    [ 'c', [], 1 ]
  ], 1 ]
```

## comparison operations

```flor
  a < b
```
parses to
```ruby
  [ '<', [ [ 'a', [], 1 ], [ 'b', [], 1 ] ], 1 ]
```
---

```flor
  a > b
```
parses to
```ruby
  [ '>', [ [ 'a', [], 1 ], [ 'b', [], 1 ] ], 1 ]
```
---

```flor
  a <= b
```
parses to
```ruby
  [ '<=', [ [ 'a', [], 1 ], [ 'b', [], 1 ] ], 1 ]
```
---

```flor
  a >= b
```
parses to
```ruby
  [ '>=', [ [ 'a', [], 1 ], [ 'b', [], 1 ] ], 1 ]
```
---

```flor
  a = b
```
parses to
```ruby
  [ '=', [ [ 'a', [], 1 ], [ 'b', [], 1 ] ], 1 ]
```
---

```flor
  a == b
```
parses to
```ruby
  [ '==', [ [ 'a', [], 1 ], [ 'b', [], 1 ] ], 1 ]
```

## lines

```flor
  sequence
```
parses to
```ruby
  [ 'sequence', [], 1 ]
```
---

```flor
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

```flor
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

```flor
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

```flor
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

```flor
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

```flor
  sequence vars: {}
    task nada, cc: []
```
parses to
```ruby
  [ 'sequence', [
    [ '_att', [
      [ 'vars', [], 1 ],
      [ '_obj', [
        [ '_att', [
          [ '_', [], 1 ]
        ], 1 ]
      ], 1 ]
    ], 1 ],
    [ 'task', [
      [ '_att', [ [ 'nada', [], 2 ] ], 2 ],
      [ '_att', [
        [ 'cc', [], 2 ],
        [ '_arr', [
          [ '_att', [
            [ '_', [], 2 ]
          ], 2 ]
        ], 2 ]
      ], 2 ]
    ], 2 ]
  ], 1 ]
```

## lines with attributes

```flor
  sequence timeout:
    '1h'
```
parses to
```ruby
  [ 'sequence',
    [ [ '_att', [ [ 'timeout', [], 1 ], [ '_sqs', '1h', 2 ] ], 1 ] ],
    1 ]
```
---

```flor
  sequence timeout: '1h',
    vars: {}
```
parses to
```ruby
  [ 'sequence',
    [ [ '_att', [
      [ 'timeout', [], 1 ],
      [ '_sqs', '1h', 1 ]
    ], 1 ],
      [ '_att', [
        [ 'vars', [], 2 ],
        [ '_obj', [
          [ '_att', [
            [ '_', [], 2 ]
          ], 2 ]
        ], 2 ]
      ], 2 ] ],
    1 ]
```

```flor
  task 'bob',
    context: 'customer has a leak in kitchen',
    mission: 'investigate leak'
```
parses to
```ruby
  [ "task",
    [ [ "_att", [ [ "_sqs", "bob", 1 ] ], 1 ],
      [ "_att",
        [ [ "context", [], 2 ],
          [ "_sqs", "customer has a leak in kitchen", 2 ] ],
        2 ],
      [ "_att",
        [ [ "mission", [], 3 ], [ "_sqs", "investigate leak", 3 ] ],
        3 ] ],
   1 ]
```

## lines with regexes

```flor
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

```flor
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
```flor
  hello /world/
```
parses to
```ruby
  [ 'hello', [ [ '_att', [ [ '_rxs', '/world/', 1 ] ], 1 ], ], 1 ]
```
---

```flor
  hello, /world/
```
parses to
```ruby
  [ 'hello', [ [ '_att', [ [ '_rxs', '/world/', 1 ] ], 1 ], ], 1 ]
```
---

```flor
  hello (/world/)
```
parses to
```ruby
  [ 'hello', [ [ '_att', [ [ '_rxs', '/world/', 1 ] ], 1 ], ], 1 ]
```
---

```flor
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

```flor
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

```flor
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

```flor
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

```flor
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

```flor
  [ 1,
  
  2,

    4 ]
```
parses to
```ruby
  [ '_arr', [
    [ '_num', 1, 1 ], [ '_num', 2, 3 ], [ '_num', 4, 5 ]
  ], 1 ]
```

---

```flor
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

```flor
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

```flor
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

```flor
  sequence a, b, [ 1,
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

```flor
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

```flor
  map,
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

```flor
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

```flor
  (sleep '3h') timeout: '2h'
```
parses to
```ruby
  [ 'sequence', [
    [ 'set', [
      [ '_head_XXX', [], 1 ],
      [ 'sleep', [ [ '_att', [ [ '_sqs', '3h', 1 ] ], 1 ] ], 1 ]
    ], 1 ],
    [ '_head_XXX', [
      [ '_att', [ [ 'timeout', [], 1 ], [ '_sqs', '2h', 1 ] ], 1 ]
    ], 1 ]
  ], 1 ]
```
---

```flor
  (def x y \ (+ x y)) 7 2
```
parses to
```ruby
  [ 'sequence', [
    [ 'set', [
      [ '_head_XXX', [], 1 ],
      [ 'def', [
        [ '_att', [ [ 'x', [], 1 ] ], 1 ],
        [ '_att', [ [ 'y', [], 1 ] ], 1 ],
        [ '+', [ [ 'x', [], 1 ], [ 'y', [], 1 ] ], 1 ]
      ], 1 ],
    ], 1 ],
    [ '_head_XXX', [
      [ '_att', [ [ '_num', 7, 1 ] ], 1 ],
      [ '_att', [ [ '_num', 2, 1 ] ], 1 ]
    ], 1 ]
  ], 1 ]
```
---

```flor
  (def x \ (+ x 3)) 2 if true
```
parses to
```ruby
  [ 'if', [
    [ '_boo', true, 1 ],
    [ 'sequence', [
      [ 'set', [
        [ '_head_XXX', [], 1 ],
        [ "def", [
          [ "_att", [ [ "x", [], 1 ] ], 1 ],
          [ "+", [ [ "x", [], 1 ], [ "_num", 3, 1 ] ], 1 ]
        ], 1 ],
      ], 1 ],
      [ '_head_XXX', [
        [ "_att", [ [ "_num", 2, 1 ] ], 1 ]
      ], 1 ]
    ], 1 ]
  ], 1 ]
```

## dollar

```flor
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
    [ 'sequence', [
      [ 'set', [
        [ '_head_XXX', [], 4 ],
        [ '_dqs', '$(f.a)-$(f.b)', 4 ]
      ], 4 ],
      [ '_head_XXX', [
        [ '_att', [ [ '_num', 1, 4 ] ], 4 ]
      ], 4 ]
    ], 4 ]
  ], 1 ]
```
---


## backslash

```flor
  a \ b
```
parses to
```ruby
  [ 'a', [ [ 'b', [], 1 ] ], 1 ]
```
---

```flor
  a \
b
```
parses to
```ruby
  [ 'a', [ [ 'b', [], 2 ] ], 1 ]
```
---

```flor
  a \
  b
  c
```
parses to
```ruby
  [ 'sequence',
    [ [ 'a', [ [ 'b', [], 2 ] ], 1 ] , [ 'c', [], 3 ] ],
    0 ]
```
---

```flor
  a
\ b
```
parses to
```ruby
  [ 'a', [ [ 'b', [], 2 ] ], 1 ]
```
---

```flor
  map [ 1, 2 ] \ def x \ + 1 x
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

```flor
  set f0 (def \ 2)
```
parses to
```ruby
  [ 'set', [
    [ '_att', [
      [ 'f0', [], 1 ]
    ], 1 ],
    [ '_att', [
      [ 'def', [ [ '_num', 2, 1 ] ], 1 ]
    ], 1 ]
  ], 1 ]
```
---

```flor
  set f0 (def \ 2)
  f0 _
```
parses to
```ruby
  [ 'sequence', [
    [ 'set', [
      [ '_att', [
        [ 'f0', [], 1 ]
      ], 1 ],
      [ '_att', [
        [ 'def', [ [ '_num', 2, 1 ] ], 1 ]
      ], 1 ]
    ], 1 ],
    [ 'f0', [
      [ '_att', [
        [ '_', [], 2 ]
      ], 2 ]
    ], 2 ]
  ], 0 ]
```


## semicolon and pipe

```flor
  1; 2
```
parses to
```ruby
  [ 'sequence', [ [ '_num', 1, 1 ], [ '_num', 2, 1 ] ], 0 ]
```
---

```flor
  1; 2
```
parses to
```ruby
  [ 'sequence', [ [ '_num', 1, 1 ], [ '_num', 2, 1 ] ], 0 ]
```
---

```flor
  1 | 2
```
parses to
```ruby
  [ 'sequence', [ [ '_num', 1, 1 ], [ '_num', 2, 1 ] ], 0 ]
```
---

```flor
  sequence \ a |  b |  c
```
parses to
```ruby
  [ 'sequence', [
    [ 'a', [], 1 ], [ 'b', [], 1 ], [ 'c', [], 1 ]
  ], 1 ]
```
---

```flor
  sequence
\a
    b | c ; d
```
parses to
```ruby
  [ 'sequence', [
    [ 'a', [], 2 ], [ 'b', [], 3 ], [ 'c', [], 3 ], [ 'd', [], 3 ]
  ], 1 ]
```
---

```flor
  def msg \ hole _
```
parses to
```ruby
  [ "def",
    [ [ "_att", [ [ "msg", [], 1 ] ], 1 ],
      [ "hole", [ [ "_att", [ [ "_", [], 1 ] ], 1 ] ], 1 ] ],
    1 ]
```


## suffix if and unless

```flor
  push 7 if a > b
```
parses to
```ruby
  [ 'if', [
    [ '>', [ [ 'a', [], 1 ], [ 'b', [], 1 ] ], 1 ],
    [ 'push', [ [ '_att', [ [ '_num', 7, 1 ] ], 1 ] ], 1 ]
  ], 1 ]
```
---

```flor
  push 8 unless a > b
```
parses to
```ruby
  [ 'unless', [
    [ '>', [ [ 'a', [], 1 ], [ 'b', [], 1 ] ], 1 ],
    [ 'push', [ [ '_att', [ [ '_num', 8, 1 ] ], 1 ] ], 1 ]
  ], 1 ]
```
---

```flor
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
---

```flor
  continue _ if a >= b
```
parses to
```ruby
  [ 'if', [
    [ '>=', [ [ 'a', [], 1 ], [ 'b', [], 1 ] ], 1 ],
    [ 'continue', [ [ '_att', [ [ '_', [], 1 ] ], 1 ] ], 1 ]
  ], 1 ]
```
---

```flor
  3 if a >= b
```
parses to
```ruby
  [ 'if', [
    [ '>=', [ [ 'a', [], 1 ], [ 'b', [], 1 ] ], 1 ],
    [ '_num', 3, 1 ]
  ], 1 ]
```


## misc

```flor
  { sto_uri: (ife \ true | 10 | 11) a: 1 }
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

```flor
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

```flor
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
---

```flor
  do-that-other-thing _
```
parses to
```ruby
  [ 'do-that-other-thing', [ [ '_att', [ [ '_', [], 1 ] ], 1 ], ], 1 ]
```

