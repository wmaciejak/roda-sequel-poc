Sequel.migration do
  up do
    run <<-SQL
      ALTER TABLE sectors
      ADD CONSTRAINT non_negative_available_tickets_count
      CHECK (available_tickets_count >= 0)
    SQL
  end

  down do
    run <<-SQL
      ALTER TABLE sectors
      DROP CONSTRAINT non_negative_available_tickets_count
    SQL
  end
end
