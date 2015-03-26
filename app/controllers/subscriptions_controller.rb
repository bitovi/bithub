class SubscriptionsController < ApplicationController
  before_filter :authenticate_account!
  load_and_authorize_resource

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

    render html: 'OK', layout: 'admin'
  end

  private

  def create_params
    params.require(:plan)
    params.require(:stripe_token)
    params
  end
end
