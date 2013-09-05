class RenameThreadUpdatedAt < ActiveRecord::Migration
  def up
    rename_column :events, :thread_updated_at, :thread_updated_ts
  end

  def down
    rename_column :events, :thread_updated_ts, :thread_updated_at
  end
end
