# encoding: utf-8

Sequel.migration do
  change do
    create_table(:revisions) do
      primary_key :id
      String :raw_body, null: false, text: true
      String :compiled, null: false, text: true
    end
  end
end
