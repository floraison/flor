
# flor

[![Build Status](https://secure.travis-ci.org/floraison/flor.svg)](http://travis-ci.org/floraison/flor)
[![Gem Version](https://badge.fury.io/rb/flor.svg)](http://badge.fury.io/rb/flor)

Flor is a "Ruby workflow engine", if that makes any sense.

## Documentation

see [doc/](tree/master/doc).

## Running the specs

    LOG_DBG_KEYS = %w[ dbg msg err src tree run ]
    LOG_ALL_KEYS = %w[ all log sto ] + LOG_DBG_KEYS

##### setting FLOR_DEBUG

```
FLOR_DEBUG=db bundle exec rspec spec/punit/cancel_spec.rb
  # don't do anything at all
```
```FLOR_DEBUG=msg bundle exec rspec spec/punit/cancel_spec.rb```
```FLOR_DEBUG=err bundle exec rspec spec/punit/cancel_spec.rb```
```FLOR_DEBUG=src bundle exec rspec spec/punit/cancel_spec.rb```
```FLOR_DEBUG=run bundle exec rspec spec/punit/cancel_spec.rb```
```FLOR_DEBUG=tree bundle exec rspec spec/punit/cancel_spec.rb```
```FLOR_DEBUG=sto bundle exec rspec spec/punit/cancel_spec.rb```

```FLOR_DEBUG=dbg bundle exec rspec spec/punit/cancel_spec.rb```
is equivalent to
```FLOR_DEBUG=msg,err,src,tree,run bundle exec rspec spec/punit/cancel_spec.rb```

and

```FLOR_DEBUG=all bundle exec rspec spec/punit/cancel_spec.rb```
is equivalent to
```FLOR_DEBUG=msg,err,src,tree,run,log,sto bundle exec rspec spec/punit/cancel_spec.rb```


## LICENSE

MIT, see [LICENSE.txt](LICENSE.txt)

