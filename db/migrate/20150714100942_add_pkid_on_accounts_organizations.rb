class AddPkidOnAccountsOrganizations < ActiveRecord::Migration
  def change
    add_column :accounts_organizations, :id, :primary_key
  end if Apartment::Tenant.current == 'public'
end
