class Organization < ActiveRecord::Base

  has_many :account_organizations, dependent: :destroy
  has_many :accounts, through: :account_organizations

  has_many :brands, dependent: :destroy

  has_many :monthly_billings
  has_one  :subscription, dependent: :destroy
end
