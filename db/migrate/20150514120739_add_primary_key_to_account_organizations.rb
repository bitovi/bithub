class AddPrimaryKeyToAccountOrganizations < ActiveRecord::Migration
  def up
    if Apartment::Tenant.current == 'public' && !column_exists?(:accounts_organizations, :id)
      add_column :accounts_organizations, :id, :primary_key
    end
  end

  def down
    if Apartment::Tenant.current == 'public' && column_exists?(:accounts_organizations, :id)
      remove_column :accounts_organizations, :id
    end
  end
end
