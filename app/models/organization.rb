class Organization < ActiveRecord::Base

  has_many :user_organizations, dependent: :destroy
  has_many :users, through: :user_organizations

  has_many :brands, dependent: :destroy

  has_many :monthly_billings
  has_one  :subscription, dependent: :destroy
end
