class Organization < ActiveRecord::Base

  has_many :accounts, through: :accounts_organizations
  has_many :accounts_organizations, dependent: :destroy

  has_many :brands, dependent: :destroy

  has_many :monthly_billings

  has_one  :subscription, dependent: :destroy
end
