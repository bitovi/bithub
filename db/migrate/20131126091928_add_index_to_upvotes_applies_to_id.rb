class AddIndexToUpvotesAppliesToId < ActiveRecord::Migration
  def change
    add_index(:upvotes, :applies_to_id)
  end
end
