class Api::V3::PaymentsController < Api::V3::BaseController
  before_filter :authenticate_account!
  load_and_authorize_resource

  def index
    @payments = current_brand.payments.order(created_at: :desc)
    render :index
  end
end
