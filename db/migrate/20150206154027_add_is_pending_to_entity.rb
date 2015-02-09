class AddIsPendingToEntity < ActiveRecord::Migration
  def change
    add_column :entities, :is_pending, :boolean, default: false
  end
end
