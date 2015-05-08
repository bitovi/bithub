class Api::V3::AccountsController < Api::V3::BaseController
  before_filter :authenticate_account!

  def current
    authorize!(:read, @account = current_account)
    render :show
  end

end
