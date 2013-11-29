class AddTotalUpvotesToEvents < ActiveRecord::Migration
  def up
    add_column :events, :total_upvotes, :integer, :default => 0

    execute <<-SQL
      CREATE VIEW event_total_upvotes AS
      SELECT e.id AS event_id, sum(u.value) AS upvotes_sum
      FROM events AS e, upvotes AS u
      WHERE e.id = u.applies_to_id
      GROUP BY e.id;
    SQL
  end

  def down
    remove_column :events, :total_upvotes

    execute <<-SQL
      DROP VIEW IF EXISTS event_total_upvotes;
    SQL
  end
end
