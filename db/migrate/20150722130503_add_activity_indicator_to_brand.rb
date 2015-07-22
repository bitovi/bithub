class AddActivityIndicatorToBrand < ActiveRecord::Migration
  def up
    add_column :brands, :is_active, :boolean, default: true
  end

  def down
    remove_column :brands, :is_active
  end
end
