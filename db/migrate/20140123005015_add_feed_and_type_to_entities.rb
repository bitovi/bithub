class AddFeedAndTypeToEntities < ActiveRecord::Migration
  def change
    change_table :entities do |t|
      t.column :feed_name, :string
      t.column :type_name, :string
      t.column :category_name, :string
    end
  end
end
