class Api::V3::PaymentsController < Api::V3::BaseController
  before_filter :authenticate_account!

  def index
    # TODO how to authorize?
    @payments = current_brand.payments.order(created_at: :desc)
    render :index
  end
end
