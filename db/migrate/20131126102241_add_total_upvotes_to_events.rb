class AddTotalUpvotesToEvents < ActiveRecord::Migration
  def change
    add_column :events, :total_upvotes, :integer, :default => 0
  end
end
