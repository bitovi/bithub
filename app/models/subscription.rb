class Subscription < ActiveRecord::Base
  include Stripe::Callbacks

  belongs_to :organization
  belongs_to :plan
  has_many :payments

  # validates :plan_id, :presence => true

  before_destroy :delete_stripe_customer

  # after_customer_subscription_updated! do |subscription, event|
  #   self.update_from_subscription(subscription, event_id: event.id)
  # end

  def card
    if has_card?
      {
        exp_month: card_exp_month,
        exp_year: card_exp_year,
        type: card_type,
        last4: card_last4
      }
    end
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

  def chargeable?
    Rails.env.development? || !!(stripe_customer_id && has_card?)
  end

  def has_card?
    !!(card_exp_month && card_exp_year && card_type && card_last4)
  end

  # def update_plan(stripe_plan_id)
  #   stripe_customer = Stripe::Customer.retrieve self.stripe_customer_id
  #   stripe_subscription = stripe_customer.subscriptions.retrieve self.stripe_subscription_id
  #   stripe_subscription.plan = stripe_plan_id

  #   if stripe_subscription.save
  #     if plan = Plan.find_by_stripe_id(stripe_plan_id)
  #       update_attributes!({plan: plan})
  #     end
  #   end
  # end

  # def self.update_from_subscription(subscription, opts={})
  #   attrs = {
  #     stripe_event_id: opts[:event_id],
  #     stripe_subscription_status: subscription.status,
  #   }

  #   if existing = self.find_by_customer_id(subscription.customer)
  #     unless existing.update_attributes(attrs)
  #       Rails.logger.warn "[Stripe Webhook] Updating subscription '#{subscription.id}' failed! \n#{existing.errors.messages}"
  #     end
  #   else
  #     Rails.logger.warn "[Stripe Webhook] Subscription '#{subscription.id}' not found!"
  #   end
  # end

  def self.find_by_customer_id(id)
    where(stripe_customer_id: id).order(:created_at).last
  end

  # def self.available_plans
  #   Stripe::Plans.constants.map {|p| p.to_s.downcase}.reject {|p| p == 'configuration'}
  # end

  def self.current
    # TODO: determine through organization
    Brand.find_by_tenant_name( Apartment::Tenant.current ).organization.subscription
  end

  def create_stripe_customer!
    if stripe_customer_id
      customer = Stripe::Customer.retrieve stripe_customer_id
      Rails.logger.info "Stripe customer #{customer.id} already exists for org #{organization.name}"
    else
      Rails.logger.info "Creating Stripe customer for org #{organization.name}"
      customer = Stripe::Customer.create ### plan: plan.stripe_id
    end

    subscription = customer.subscriptions.data.first

    self.stripe_customer_id = customer.id
    self.stripe_subscription_id = subscription.id
    self.stripe_subscription_status = subscription.status
    self.save!
  end

  def delete_stripe_customer
    if stripe_customer_id
      Rails.logger.info "Deleting Stripe customer for org #{organization.name} with stripe_customer_id: #{stripe_customer_id}"

      stripe_customer = Stripe::Customer.retrieve stripe_customer_id
      stripe_customer.delete
    end
  end

end
