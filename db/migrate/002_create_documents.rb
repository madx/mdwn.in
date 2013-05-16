# encoding: utf-8

Sequel.migration do
  change do
    create_table(:documents) do
      primary_key :id
      String :key, null: false, unique: true
    end
  end
end
