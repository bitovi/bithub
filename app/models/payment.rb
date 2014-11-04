class Payment < ActiveRecord::Base
  include Stripe::Callbacks

  belongs_to :brand

  after_invoice_payment_succeeded! do |invoice, event|
    new_invoice =  self.new_from_invoice(invoice, event_id: event.id)

    unless new_invoice.save
      Rails.logger.warn "[Stripe Webhook] Saving invoice '#{invoice.id}' failed! \n#{new_invoice.errors.messages}"
    end
  end

  def self.new_from_invoice(invoice, opts={})
    brand = Subscription.find_by_customer_id(invoice.customer).brand
    plan  = invoice.lines.data.first.plan

    attrs = {
      total: invoice.total,
      currency: invoice.currency,

      plan_id: plan.id,

      period_start: Time.at(invoice.period_start),
      period_end: Time.at(invoice.period_end),

      stripe_event_id: opts[:event_id],
      stripe_invoice_id: invoice.id,
      stripe_customer_id: invoice.customer,
      stripe_subscription_id: invoice.subscription,

      brand_id: brand.id
    }

    self.new(attrs)
  end
end
