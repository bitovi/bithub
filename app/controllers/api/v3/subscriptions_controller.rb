class Api::V3::SubscriptionsController < Api::V3::ApiController

  def show
    authorize! :show, a_subscription
    render :show
  end

  def current
    @subscription = current_organization.subscription
    render :show
  end

  private

  def a_subscription
    @subscription = Subscription.find subscription_id
  end

  def subscription_id
    params.require(:id)
  end

end
