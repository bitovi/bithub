class MonthlyBilling < ActiveRecord::Base

  belongs_to :organization
  has_many :monthly_billing_records

  validates_presence_of :organization_id, :period_beginning, :period_end, :total

end
