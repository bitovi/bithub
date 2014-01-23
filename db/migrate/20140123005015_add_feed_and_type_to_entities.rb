class AddFeedAndTypeToEntities < ActiveRecord::Migration
  def change
    change_table :entities do |t|
      t.column :feed, :string
      t.column :type, :string
    end
  end
end
