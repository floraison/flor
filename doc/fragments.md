
# fragments.md

Fragments of documentation that will be reused later on.

---


## Running the specs

(Most of the time, as developer of flor, I'm writing specs, running them with `FLOR_DEBUG=dbg` and hammering the code until the specs are green. The following lines are about setting `FLOR_DEBUG` for flor development).

##### setting FLOR_DEBUG

This is a targetted run of a spec file:
```
FLOR_DEBUG=msg,err bundle exec rspec spec/punit/cancel_spec.rb
```

* `msg` displays the flor messages in a summary, colored format
* `err` displays errors with details, when and if they happen
* `src` displays the source before it gets parsed and launched
* `tree` displays the syntax tree as parsed from the source, right before launch
* `run` shows info about each [run](doc/glossary.md#run) that just ended
* `sto` displays debug information about the [storage](doc/glossary.md#storage), it's mostly SQL statements

#### `FLOR_DEBUG=dbg` and `FLOR_DEBUG=all`

There are two shortcuts for the flags above:
```
FLOR_DEBUG=dbg bundle exec rspec spec/punit/cancel_spec.rb
  # is equivalent to
FLOR_DEBUG=msg,err,src,tree,run bundle exec rspec spec/punit/cancel_spec.rb
```
and
```
FLOR_DEBUG=all bundle exec rspec spec/punit/cancel_spec.rb
  # is equivalent to
FLOR_DEBUG=msg,err,src,tree,run,log,sto bundle exec rspec spec/punit/cancel_spec.rb
```

I tend to use `FLOR_DEBUG=dbg` when developping flor.

