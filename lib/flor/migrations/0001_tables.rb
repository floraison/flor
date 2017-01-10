
Sequel.migration do

  up do

    create_table :flor_messages do

      primary_key :id, type: Bignum
      String :domain, null: false
      String :exid, null: false
      String :point, null: false # 'execute', 'task', 'receive', 'schedule', ...
      File :content # JSON
      String :status, null: false
      String :ctime
      String :mtime

      index :exid
    end

    create_table :flor_executions do

      primary_key :id, type: Bignum
      String :domain, null: false
      String :exid, null: false
      File :content # JSON
      String :status, null: false # 'active' or something else like 'archived'
      String :ctime
      String :mtime

      index :exid
    end

    create_table :flor_timers do

      primary_key :id, type: Bignum
      String :domain, null: false
      String :exid, null: false
      String :nid, null: false
      String :type, null: false # 'at', 'in', 'cron', 'every', ...
      String :schedule, null: false # '20141128.103239' or '00 23 * * *'
      String :ntime # next time
      File :content # JSON msg to trigger
      Bignum :count, null: false
      String :status, null: false
      String :ctime
      String :mtime

      index :exid
      index [ :exid, :nid ]
    end

    create_table :flor_traps do

      primary_key :id, type: Bignum
      String :domain, null: false
      String :exid, null: false
      String :onid, null: false
      String :nid, null: false
      #
      TrueClass :tconsumed, null: false, default: false
      String :trange, null: false
      String :tpoints, null: true
      String :ttags, null: true
      String :theats, null: true
      String :theaps, null: true
      #
      File :content # JSON msg to trigger
      #
      String :status, null: false
      String :ctime
      String :mtime

      index :exid
      index [ :exid, :nid ]
    end

    create_table :flor_traces do

      primary_key :id, type: Bignum
      String :domain, null: false
      String :exid, null: false
      String :nid, null: true
      String :tracer, null: false # 'executor', 'trace'
      String :text, null: false # 'blah blah blah'
      String :tstamp

      index :exid
    end
  end

  down do

    drop_table :flor_messages
    drop_table :flor_executions
    drop_table :flor_timers
    drop_table :flor_traps
    drop_table :flor_traces
  end
end

