class Subscription < ActiveRecord::Base
  include Stripe::Callbacks

  belongs_to :brand

  validates :plan_id, :presence => true
  validates :brand_id, :presence => true

  before_destroy :delete_stripe_customer

  after_customer_subscription_updated! do |subscription, event|
    self.update_from_subscription(subscription, event_id: event.id)
  end

  def initialize(attrs={})
    super

    customer = Stripe::Customer.create plan: self.plan_id
    subscription = customer.subscriptions.data.first

    self.stripe_customer_id = customer.id
    self.stripe_subscription_id = subscription.id
    self.stripe_subscription_status = subscription.status
  end

  def update_card(stripe_token)
    stripe_customer = Stripe::Customer.retrieve self.stripe_customer_id
    stripe_customer.card = stripe_token

    if stripe_customer.save
      card = stripe_customer.cards.data.first

      self.update_attributes({
        card_exp_month: card.exp_month,
        card_exp_year: card.exp_year,
        card_type: card.brand,
        card_last4: card.last4
      })
    end
  end

  def update_plan(plan)
    stripe_customer = Stripe::Customer.retrieve self.stripe_customer_id
    stripe_subscription = stripe_customer.subscriptions.retrieve self.stripe_subscription_id
    stripe_subscription.plan = plan

    if stripe_subscription.save
      # should be updated via webhook as well, but let's make it immediately
      update_attribute('plan_id', plan_id)
    end
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

  private

  def delete_stripe_customer
    Rails.logger.info "Deleting subscription #{self}"

    stripe_customer = Stripe::Customer.retrieve stripe_customer_id
    stripe_customer.delete
  end

end
