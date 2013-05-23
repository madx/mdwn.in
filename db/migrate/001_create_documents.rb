# encoding: utf-8

Sequel.migration do
  change do
    create_table(:documents) do
      primary_key :id
      String :key, null: false, unique: true
      Strong :read_only_key, null: false
      String :raw_body, null: false, text: true
      String :compiled, null: false, text: true

      index :key
      index :read_only_key
    end
  end
end
