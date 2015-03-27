class Api::V3::SubscriptionsController < Api::V3::BaseController
  before_filter :authenticate_account!
  load_and_authorize_resource

  def show
    @subscription = Subscription.first
    render :show
  end

end
