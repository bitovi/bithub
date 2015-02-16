class ChangeDefaultFilterState < ActiveRecord::Migration
  def change
    change_column :embeds, :approved_by_default, :boolean
  end
end
