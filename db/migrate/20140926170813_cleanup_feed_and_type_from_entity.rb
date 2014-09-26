class CleanupFeedAndTypeFromEntity < ActiveRecord::Migration
  def change
    remove_column :entities, :feed_id
    remove_column :entities, :type_id
  end
end
