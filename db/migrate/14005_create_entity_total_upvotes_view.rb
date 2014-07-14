class CreateEntityTotalUpvotesView < ActiveRecord::Migration
  def up
    execute <<-TOTAL_UPVOTES
      CREATE VIEW entity_total_upvotes AS
      SELECT e.id AS entity_id, sum(u.value) AS upvotes_sum
      FROM entities AS e, upvotes AS u
      WHERE e.id = u.applies_to_id
      GROUP BY e.id;
    TOTAL_UPVOTES
  end

  def down
  end
end
