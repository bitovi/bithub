class AddTotalUpvotesToEvents < ActiveRecord::Migration
  def change
    add_column :events, :total_upvotes, :integer
  end
end
