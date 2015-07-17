class AddWasViewedToEvents < ActiveRecord::Migration
  def up
    add_column :events, :was_viewed, :boolean, default: false
  end

  def down
    remove_column :events, :was_viewed
  end
end
