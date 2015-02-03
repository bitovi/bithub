class AddIsPinnedToEntity < ActiveRecord::Migration
  def change
    add_column :entities, :is_pinned, :boolean, default: false
  end
end
