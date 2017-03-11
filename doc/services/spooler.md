
# spooler service

The spooler is a service that watches a directory for incoming flor messages stored in JSON.

If it cannot parse the incoming JSON files, it will move them to the `rejected/` sub directory along with a text file detailing the error.

By default, the spooler will watch the `var/spool/` directory (and reject to the `var/spool/rejected/` directory). This can be changed via the `spo_dir` configuration key.

If, upon unit start, the spool dir is not present or is not a dir, the spooler will simply not become active.

## use cases

###

## links

* [source](https://github.com/floraison/flor/tree/master/lib/flor/unit/spooler.rb)
* [spec](https://github.com/floraison/flor/tree/master/spec/unit/spooler_spec.rb)

