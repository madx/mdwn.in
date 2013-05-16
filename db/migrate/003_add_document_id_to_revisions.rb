# encoding: utf-8

Sequel.migration do
  change do
    alter_table(:revisions) do
      add_foreign_key :document_id, :documents
    end
  end
end
