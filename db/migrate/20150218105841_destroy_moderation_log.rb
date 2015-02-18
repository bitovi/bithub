class DestroyModerationLog < ActiveRecord::Migration
  def change
    drop_table :moderation_logs
  end
end
