class AddColCategoryOnEvents < ActiveRecord::Migration
  def up
    add_column :events, :category_id, :integer
  end

  def down
    remove_column :events, :category_id
  end
end
