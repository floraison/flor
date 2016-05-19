
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
      File :content # JSON
      String :status, null: false
      Time :ctime
      Time :mtime

      index :exid
    end

    create_table :flon_logs do

      primary_key :id, type: Bignum
      String :exid, null: false
      String :reporter, null: false # 'dispatcher'
      String :subject, null: false # 'execution x', 'node y'
      String :point, null: false # 'dispatch', 'task', 'fail'
      String :action, null: false # 'dispatch', 'task', 'fail'
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

