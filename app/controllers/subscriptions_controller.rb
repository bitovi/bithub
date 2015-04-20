class SubscriptionsController < ApplicationController
  #before_filter :authenticate_account!
  #load_and_authorize_resource

  after_action :allow_iframe, only: [:edit_cc, :edit_plan]

  def edit_plan
    @plan = Subscription.current.plan
    @plans = Plan.all

    render :edit_plan, layout: 'admin'
  end

  def edit_cc
    render :edit_cc, layout: 'admin'
  end

  def update
    subscription = Subscription.current

    if stripe_token = params['stripe_token']
      subscription.update_card stripe_token
    end

    if plan = params['plan']
      subscription.update_plan plan
    end

    render :success_info, layout: 'admin'
  end

  private

  def create_params
    params.require(:plan)
    params.require(:stripe_token)
    params
  end

  

  def allow_iframe
    response.headers.except! 'X-Frame-Options'
  end
end
