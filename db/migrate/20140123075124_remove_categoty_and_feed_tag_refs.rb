class RemoveCategotyAndFeedTagRefs < ActiveRecord::Migration
  def up
    remove_column :entities, :feed_id
    remove_column :entities, :category_id
  end

  def down
    add_column :entities, :feed_id, :integer
    add_column :entities, :category_id, :integer
  end
end
