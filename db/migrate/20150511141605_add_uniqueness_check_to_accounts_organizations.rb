class AddUniquenessCheckToAccountsOrganizations < ActiveRecord::Migration
  def up
    execute "alter table accounts_organizations add constraint no_double_links unique (account_id, organization_id);"
  end

  def down
    execute "alter table accounts_organizations drop constraint no_double_links;"
  end
end
