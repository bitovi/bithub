class AddInvitationFieldsToAccountOrganization < ActiveRecord::Migration
  def up
    if Apartment::Tenant.current == 'public'
      add_column :account_organizations, :invitation_created_at, :datetime
      add_column :account_organizations, :invitation_accepted_at, :datetime

      add_reference :account_organizations, :invited_by_account
    end
  end

  def down
    if Apartment::Tenant.current == 'public'
      remove_column :account_organizations, :invitation_created_at, :datetime
      remove_column :account_organizations, :invitation_accepted_at, :datetime

      remove_reference :account_organizations, :invited_by_account
    end
  end
end
