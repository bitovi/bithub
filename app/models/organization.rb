class Organization < ActiveRecord::Base

  has_and_belongs_to_many :accounts
  has_many :brands

  ### TODO: ENSURE UNSUBSCRIBE FROM STRIPE !!!!
  has_one  :subscription
  has_many :payments
end
