class AddTenantNameToBrand < ActiveRecord::Migration
  def change
    add_column :brands, :tenant_name, :string
    add_index :brands, :tenant_name, :unique => true
    add_index :brands, :name, :unique => true
  end
end
