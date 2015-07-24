class AccountOrganization < ActiveRecord::Base
  self.table_name = :accounts_organizations

  belongs_to :account
  belongs_to :organization
  
  def confirm!
    update_attribute(:invitation_accepted_at, DateTime.now)
  end

  validates_uniqueness_of :account_id, :scope => [:organization_id]
end
