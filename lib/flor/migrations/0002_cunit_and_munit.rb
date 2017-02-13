
Sequel.migration do

  up do

    alter_table :flor_messages do

      add_column :cunit, String
      add_column :munit, String
    end

    alter_table :flor_executions do

      add_column :cunit, String
      add_column :munit, String
    end

    alter_table :flor_timers do

      add_column :cunit, String
      add_column :munit, String
    end

    alter_table :flor_traps do

      add_column :cunit, String
      add_column :munit, String
    end

    alter_table :flor_pointers do

      add_column :cunit, String
    end

    alter_table :flor_traces do

      add_column :cunit, String
    end
  end

  down do

    alter_table :flor_messages do

      drop_column :cunit
      drop_column :munit
    end

    alter_table :flor_executions do

      drop_column :cunit
      drop_column :munit
    end

    alter_table :flor_timers do

      drop_column :cunit
      drop_column :munit
    end

    alter_table :flor_traps do

      drop_column :cunit
      drop_column :munit
    end

    alter_table :flor_pointers do

      drop_column :cunit
    end

    alter_table :flor_traces do

      drop_column :cunit
    end
  end
end

