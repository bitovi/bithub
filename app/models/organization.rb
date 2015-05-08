class Organization < ActiveRecord::Base

  has_many :accounts, through: :accounts_organizations
  has_many :accounts_organizations, dependent: :destroy

  has_many :brands

  ### TODO: ENSURE UNSUBSCRIBE FROM STRIPE !!!!
  has_one  :subscription
end
