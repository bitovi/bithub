class SubscriptionsController < ApplicationController

  def new
    @plan = params.fetch('plan')

    render :new, layout: 'admin'
  end

  def create
    description = session.fetch('tenant_name')
    plan = create_params[:plan]
    stripe_token = create_params[:stripe_token]
    current_brand = Brand.find_by_tenant_name(session['tenant_name'])

    customer = Stripe::Customer.create(description: description, plan: plan, card: stripe_token)
    subscription = Subscription.new_from_customer(customer, current_brand, card_token: stripe_token)

    unless subscription.save
      Rails.logger.warn "Creating subscription failed! #{subscription.errors.messages}"
    end

    render html: 'OK', layout: 'admin'
  end

  # def edit
  #   render :edit, layout: 'admin'
  # end

  def update
    plan = params.fetch('plan')
    stripe_token = params.fetch('stripe_token')

    current_brand = Brand.find_by_tenant_name(session['tenant_name'])
    subscription = current_brand.subscription

    stripe_cu = Stripe::Customer.retrieve subscription.customer_id

    # update card
    stripe_cu.card = stripe_token
    if stripe_cu.save
      subscription.update_card ###
    end

    # switch plan
    stripe_sub = stripe_cu.subscriptions.retrieve subscription.stripe_subscription_id
    stripe_sub.plan = plan
    if strupe_sub.save
      subscription.update_plan ###
    end

    render html: 'OK', layout: 'admin'
  end

  private

  def update_card

  end

  def update_plan

  end

  def create_params
    params.require(:plan, :stripe_token)
  end

end
