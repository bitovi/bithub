class Api::V3::SubscriptionsController < Api::V3::BaseController
  before_filter :authenticate_account!
  load_and_authorize_resource

  def show
    @subscription = Subscription.find subscription_id
    render :show
  end

  def current
    @subscription = Subscription.first
    render :show
  end

  private

  def subscription_id
    params.require(:id)
  end

end
