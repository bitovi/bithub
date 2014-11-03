class Payment < ActiveRecord::Base
  include Stripe::Callbacks

  belongs_to :brand

  after_invoice_payment_succeeded! do |invoice, event|
    # do something
  end
end
