Sequel.migration do
  change do
    create_table(:sectors) do
      primary_key :id
      column :tickets_count, Integer
      column :available_tickets_count, Integer
    end
  end
end
