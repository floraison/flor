
<!--
# specifying flor
#
# Mon Mar  7 06:24:41 JST 2016
-->

## atoms

```radial
  1
```
parses to
```ruby
  [ '_num', 1, 1 ]
```
---

```radial
  11.01
```
parses to
```ruby
  [ '_num', 11.01, 1 ]
```
---

```radial
  true
```
parses to
```ruby
  [ '_boo', true, 1 ]
```
---

```radial
  false
```
parses to
```ruby
  [ '_boo', false, 1 ]
```
---

```radial
  null
```
parses to
```ruby
  [ '_nul', nil, 1 ]
```
---

```radial
  abc
```
parses to
```ruby
  [ 'abc', [], 1 ]
```
---

```radial
  'def'
```
parses to
```ruby
  [ '_sqs', 'def', 1 ]
```
---

```radial
  "ghi"
```
parses to
```ruby
  [ '_dqs', 'ghi', 1 ]
```
---

```radial
  /jkl/i
```
parses to
```ruby
  [ '_rxs', '/jkl/i', 1 ]
```
---

```radial
  [ 1, 2, 3 ]
```
parses to
```ruby
  [ '_arr', [
    [ '_num', 1, 1 ], [ '_num', 2, 1 ], [ '_num', 3, 1 ]
  ], 1 ]
```
---

```radial
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

## operations

```radial
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

```radial
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

## lines

```radial
  sequence
```
parses to
```ruby
  [ 'sequence', [], 1 ]
```
---

```radial
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

```radial
  sequence a b
```
parses to
```ruby
  [ 'sequence', [
    [ 'a', [], 1 ],
    [ 'b', [], 1 ]
  ], 1 ]
```
---

```radial
  sequence a, vars: 1, timeout: 1h, b
```
parses to
```ruby
  [ 'sequence', [
    [ '_atts', [
      [ 'vars', [], 1 ], [ '_num', 1, 1 ],
      [ 'timeout', [], 1 ], [ '1h', [], 1 ]
    ], 1 ],
    [ 'a', [], 1 ],
    [ 'b', [], 1 ]
  ], 1 ]
```
---

```radial
  sequence a: 1 + 1, 2
```
parses to
```ruby
  [ 'sequence', [
    [ '_atts', [
      [ 'a', [], 1 ],
      [ '+', [
        [ '_num', 1, 1 ],
        [ '_num', 1, 1 ],
      ], 1 ]
    ], 1 ],
    [ '_num', 2, 1 ]
  ], 1 ]
```

