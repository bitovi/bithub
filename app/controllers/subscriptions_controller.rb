class SubscriptionsController < ApplicationController

  def new
    render :new, layout: 'admin'
  end

  def create
    description = session.fetch('tenant_name')
    plan = params.fetch('plan')
    stripe_token = params.fetch('stripe_token')
    current_brand = Brand.find_by_tenant_name(session['tenant_name'])

    customer = Stripe::Customer.create(description: description, plan: plan, card: stripe_token)
    subscription = Subscription.new_from_customer(customer, current_brand, card_token: stripe_token)

    unless subscription.save
      # log error
      puts "ERROR!!!!!!!!"
    end

    render html: 'OK', layout: 'admin'
  end

end
