class AddApprovedToEntities < ActiveRecord::Migration
  def change
    add_column :embeds, :approved_by_default, :boolean, default: true
  end
end
