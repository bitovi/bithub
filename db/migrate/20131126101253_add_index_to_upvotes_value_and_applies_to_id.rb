class AddIndexToUpvotesValueAndAppliesToId < ActiveRecord::Migration
  def change
    add_index(:upvotes, [:applies_to_id, :value])
  end
end
