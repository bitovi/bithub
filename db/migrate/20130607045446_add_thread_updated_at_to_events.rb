class AddThreadUpdatedAtToEvents < ActiveRecord::Migration
  def change
    add_column :events, :thread_updated_at, :datetime
  end
end
