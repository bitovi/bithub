class MonthlyBillingRecord < ActiveRecord::Base

  belongs_to :monthly_billing

  validates_presence_of :monthly_billing_id, :description, :amount, :price

end
