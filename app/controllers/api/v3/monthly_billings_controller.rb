class Api::V3::MonthlyBillingsController < Api::V3::BaseController
  before_filter :authenticate_account!

  def index
    authorize! :index, MonthlyBilling

    @billings = my_billings.order(created_at: :desc)
    render :index
  end

  def my_billings
    current_brand.organization.monthly_billings
  end

end
