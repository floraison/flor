
# +, -, *, /, %

The base implementation for + - + / %

```
(+ 1 2 3) # ==> 6

+
  1
  2
  3 # ==> 6

+ \ 1; 2; 3 # ==> 6
```

```
1 - 2 - 3 # ==> -4

-
  1
  2
  3 # ==> -4
```

```
[ 1 2 3 ]
+ _ # ==> 6

[ 2 3 4 ]
* _ # ==> 24
```

```
+ "hell" "o"
"hel" + "lo"
  # both yield "hello"
```


* [source](https://github.com/floraison/flor/tree/master/lib/flor/pcore/arith.rb)

