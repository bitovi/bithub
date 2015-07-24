class SubscriptionsController < ApplicationController

  before_filter :authenticate_account!
  after_action :allow_iframe, only: [:edit_cc, :edit_plan]
  layout :backend_admin

  def current
    @subscription = current_organization.subscription
    render :current
  end

  def edit_plan
    @plan = current_organization.subscription.plan
    @plans = Plan.where(available: true).all

    render :edit_plan, layout: 'admin'
  end

  def edit_cc
    render :edit_cc, layout: 'admin'
  end

  def update
    subscription = current_organization.subscription

    if stripe_token = params['stripe_token']
      subscription.update_card stripe_token
    end

    if plan = params['plan']
      subscription.update_plan plan
    end

    render :success_info, layout: 'admin'
  end

  private
  
  def subscription_id
    params.require(:id)
  end

  def create_params
    params.require(:plan)
    params.require(:stripe_token)
    params
  end

  def allow_iframe
    response.headers.except! 'X-Frame-Options'
  end
end
