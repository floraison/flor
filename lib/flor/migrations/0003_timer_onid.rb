
Sequel.migration do

  up do

    alter_table :flor_timers do

      add_column :onid, String
    end

    self[:flor_timers].update(onid: :nid)

    alter_table :flor_timers do

      set_column_not_null :onid
    end
      #
      # Sqlite3, for example, does that by renaming "flor_timers",
      # creating a new table with the "not null" set, then copying the
      # values of the renamed, original, table into the new table...
  end

  down do

    alter_table :flor_timers do

      drop_column :onid
    end
  end
end

