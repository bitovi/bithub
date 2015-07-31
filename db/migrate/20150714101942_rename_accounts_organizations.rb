class RenameAccountsOrganizations < ActiveRecord::Migration
  def up
    if Apartment::Tenant.current == 'public'
      rename_table :accounts_organizations, :account_organizations
    end
  end

  def down
    if Apartment::Tenant.current == 'public'
      rename_table :account_organizations, :accounts_organizations
    end
  end
end
