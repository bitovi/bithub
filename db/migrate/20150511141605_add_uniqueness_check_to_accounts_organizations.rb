class AddUniquenessCheckToAccountsOrganizations < ActiveRecord::Migration
  def up
    if Apartment::Tenant.current == 'public'
      execute "alter table accounts_organizations add constraint no_double_links unique (account_id, organization_id);"
    end
  end

  def down
    if Apartment::Tenant.current == 'public'
      execute "alter table accounts_organizations drop constraint no_double_links;"
    end
  end
end
