class AddPrimaryKeyToAccountOrganizations < ActiveRecord::Migration
  def up
    add_column :accounts_organizations, :id, :primary_key
  end

  def down
    remove_column :accounts_organizations, :id
  end
end
