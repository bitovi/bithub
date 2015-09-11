class Api::V3::PaymentsController < Api::V3::ApiController
  def index
    authorize! :index, Payment
    @payments = my_payments.order(created_at: :desc)
    render :index
  end

  def my_payments
    current_brand.organization.subscription.payments
  end
end
