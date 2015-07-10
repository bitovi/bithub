class AddDefaultApprovalOnServices < ActiveRecord::Migration
  def up
    add_column :services, :approved_by_default, :boolean
  end

  def down
    remove_column :services, :approved_by_default
  end
end
