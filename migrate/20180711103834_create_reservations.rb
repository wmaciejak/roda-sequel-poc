Sequel.migration do
  change do
    create_table(:reservations) do
      primary_key :id, :uuid, default: Sequel.function(:uuid_generate_v4)
      column :tickets_count, Integer
      column :status, String
      column :requested_at, DateTime

      foreign_key :sector_id, :sectors, type: Integer, on_delete: :cascade, null: :false
    end
  end
end
