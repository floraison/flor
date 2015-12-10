
## dbschema.md

Unfortunately have to store in a DB. Fortunately Sequel is here to help.

```ruby
DB.create_table :flor_executions do

  primary_key :id, type: Bignum
  String :domain, null: false
  String :exid, null: false
  File :content # JSON
  String :status, null: false # 'active' or something else like 'archived'
  Time :tstamp

  index :domain
  index :exid
end

DB.create_table :flor_messages do

  primary_key :id, type: Bignum
  String :type, null: false # 'execute', 'task', 'receive', 'schedule', ...
  String :domain, null: false
  String :exid, null: false
  File :content # JSON
  String :status, null: false
  Time :tstamp

  index :domain
  index :exid
end

# need for a :flor_tasks table?
```

Well, that could become a single table...

```ruby
DB[:flor_executions].where(status: 'active')
  # to list active executions
```

