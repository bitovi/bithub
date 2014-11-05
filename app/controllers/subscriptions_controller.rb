class SubscriptionsController < ApplicationController

  def edit_plan
    current_brand = Brand.find_by_tenant_name(session['tenant_name'])
    subscription = current_brand.subscription

    @plan = subscription.plan_id
    @plans = Stripe::Plans.constants.map {|p| p.to_s.downcase}.reject {|p| p == 'configuration'}

    render :edit_plan, layout: 'admin'
  end

  def edit_cc
    render :edit_cc, layout: 'admin'
  end

  def update
    current_brand = Brand.find_by_tenant_name(session['tenant_name'])
    subscription = current_brand.subscription

    if stripe_token = params['stripe_token']
      subscription.update_card stripe_token
    end

    if plan = params['plan']
      subscription.update_plan plan
    end

    render html: 'OK', layout: 'admin'
  end

  private

  def create_params
    params.require(:plan)
    params.require(:stripe_token)
    params
  end
end
