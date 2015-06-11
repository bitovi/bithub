class AddDefaultApprovalOnServices < ActiveRecord::Migration
  def change
    add_column :services, :approved_by_default, :boolean
  end
end
