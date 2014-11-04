class Subscription < ActiveRecord::Base
  include Stripe::Callbacks

  belongs_to :brand

  after_customer_subscription_updated! do |subscription, event|
    self.update_from_subscription(subscription, event_id: event.id)
  end

  def self.new_from_customer(customer, brand, opts)
    card = customer.cards.data.first
    subscription = customer.subscriptions.data.first
    plan = subscription.plan

    attrs = {
      brand_id: brand.id,
      plan_id: plan.id,

      stripe_customer_id: customer.id,
      stripe_subscription_id: subscription.id,
      stripe_subscription_status: subscription.status,

      # card_token: opts[:card_token], # do we need this?
      card_exp_month: card.exp_month,
      card_exp_year: card.exp_year,
      card_type: card.brand,
      card_last4: card.last4
    }

    self.new(attrs)
  end

  def self.update_from_subscription(subscription, opts={})
    attrs = {
      plan_id: subscription.plan.id,
      stripe_event_id: opts[:event_id],
      stripe_subscription_status: subscription.status,
    }

    if existing = self.find_by_customer_id(subscription.customer)
      unless existing.update_attributes(attrs)
        Rails.logger.warn "[Stripe Webhook] Updating subscription '#{subscription.id}' failed! \n#{existing.errors.messages}"
      end
    else
      Rails.logger.warn "[Stripe Webhook] Subscription '#{subscription.id}' not found!"
    end
  end

  def self.find_by_customer_id(id)
    where(stripe_customer_id: id).order(:created_at).last
  end

end
