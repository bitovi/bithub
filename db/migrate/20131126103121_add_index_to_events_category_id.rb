class AddIndexToEventsCategoryId < ActiveRecord::Migration
  def change
    add_index(:events, :category_id)
  end
end
