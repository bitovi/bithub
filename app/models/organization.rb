class Organization < ActiveRecord::Base

  has_many :account_organizations, dependent: :destroy
  has_many :accounts, through: :account_organizations

  has_many :brands

  # TODO ensure unsubscribe from stripe !!!
  has_one :subscription
end
