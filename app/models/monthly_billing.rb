class MonthlyBilling < ActiveRecord::Base

  belongs_to :organization
  has_many :monthly_billing_records

  validates_presence_of :organization_id, :period_beginning, :period_end, :total

  before_save :update_description

  def stripe_charge!(opts={})
    return if stripe_charge_id && opts[:force] != true

    charge = Stripe::Charge.create\
      amount: total,
      currency: currency,
      customer: customer,
      description: description

    self.update_attributes!\
      stripe_customer_id: customer,
      stripe_charge_id: charge.id,
      stripe_charge_status: charge.status,
      charged_at: Time.now.utc
  end

  def customer
    organization.subscription.stripe_customer_id
  end

  def update_description
    self.description = "Billing for period #{period_beginning} - #{period_end}, TOTAL: #{total/100} #{currency}"
  end

end
