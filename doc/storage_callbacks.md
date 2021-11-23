
# storage_callbacks.md

```ruby
require 'flor/unit'

FLOR = Flor::Unit.new('flor/etc/conf.json')
FLOR.storage.on(:pointers, :any) do |table, action|
  # do something after the pointers have been updated
  # for example: update a pointer cache or etag computation to prevent
  # too many traffic between client-side and server-side...
end
FLOR.start
```

Here is a list of table/action combinations emitted by the storage:
```ruby
[ :executions, :update, id ]
[ :executions, :insert, id ]
[ :timers, :insert, id ]
[ :timers, :update, query_where, timer ]
[ :timers, :delete, query_where, timer ]
[ :traps, :insert, id ]
[ :pointers, :update, exid ]
```

Here are the possible signature for setting a callback:
```ruby
FLOR.storage.on(table, action) { |table, action, *extra| }
FLOR.storage.on(table, action) { |table, action| }
FLOR.storage.on(table, action) { |table| }
FLOR.storage.on(table, action) { }
```

