class AccountOrganization < ActiveRecord::Base
  self.table_name = :accounts_organizations

  belongs_to :account
  belongs_to :organization

  validates_uniqueness_of :account_id, :scope => [:organization_id]
end
