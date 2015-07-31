class RemoveAccountsOrganizationsFromNonPublicSchemas < ActiveRecord::Migration
  def up
    if Apartment::Tenant.current != 'public' && table_exists?(:accounts_organizations)
      drop_table :accounts_organizations
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
