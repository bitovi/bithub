class AddIndexToUpvotesValue < ActiveRecord::Migration
  def change
    add_index(:upvotes, :value)
  end
end
