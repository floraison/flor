
Sequel.migration do

  up do

    create_table :flon_messages do

      primary_key :id, type: Bignum
      String :exid, null: false
      String :point, null: false # 'execute', 'task', 'receive', 'schedule', ...
      File :content # JSON
      String :status, null: false
      Time :ctime
      Time :mtime

      index :exid
    end

    create_table :flon_executions do

      primary_key :id, type: Bignum
      String :exid, null: false
      File :content # JSON
      String :status, null: false # 'active' or something else like 'archived'
      Time :ctime
      Time :mtime

      index :exid
    end

    create_table :flon_timers do

      primary_key :id, type: Bignum
      String :exid, null: false
      String :nid, null: false
      String :type, null: false # 'at' or 'cron'
      String :schedule, null: false # '20141128.103239' or '00 23 * * *'
      Time :ntime # next time
      File :content # JSON msg to trigger
      String :status, null: false
      Time :ctime
      Time :mtime

      index :exid
      index [ :exid, :nid ]
    end

    create_table :flon_traps do

      primary_key :id, type: Bignum
      String :exid, null: false
      String :nid, null: false
      #
      String :texid, null: true
      String :tnid, null: true
      String :tpoint, null: true
      #
      File :content # JSON msg to trigger
      #
      String :status, null: false
      Time :ctime
      Time :mtime

      index :exid
      index [ :exid, :nid ]
    end

    create_table :flon_traces do

      primary_key :id, type: Bignum
      String :exid, null: false
      String :nid, null: true
      String :reporter, null: false # 'executor', 'trace'
      String :message, null: false # 'blah blah blah'
      Time :tstamp

      index :exid
    end
  end

  down do

    drop_table :flon_messages
    drop_table :flon_executions
    drop_table :flon_timers
    drop_table :flon_logs
  end
end

