class CreateModerationLog < ActiveRecord::Migration
  def change
    create_table :moderation_logs do |t|
      t.string :action
      t.string :caused_by
      t.references :entity
      t.timestamps
    end
  end
end
