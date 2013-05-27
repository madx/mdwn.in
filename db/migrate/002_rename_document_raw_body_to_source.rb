# encoding: utf-8

Sequel.migration do
  change do
    alter_table(:documents) do
      rename_column :raw_body, :source
    end
  end
end
