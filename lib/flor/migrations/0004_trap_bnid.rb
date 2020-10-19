# frozen_string_literal: true

Sequel.migration do

  up do

    alter_table(:flor_traps) { add_column :bnid, String }
    self[:flor_traps].update(bnid: :nid)
    alter_table(:flor_traps) { set_column_not_null :bnid }
  end

  down do

    alter_table(:flor_traps) { drop_column :bnid }
  end
end

