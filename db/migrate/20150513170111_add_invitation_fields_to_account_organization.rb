class AddInvitationFieldsToAccountOrganization < ActiveRecord::Migration
  def change
    change_table :accounts_organizations do |t|
      t.datetime :invitation_created_at
      t.datetime :invitation_accepted_at
      t.references :invited_by_account
    end
  end
end
