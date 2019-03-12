
Sequel.migration do

  up do

    alter_table :flor_pointers do

      add_column :content, File
    end
  end

  down do

    alter_table :flor_pointers do

      drop_column :content
    end
  end
end

