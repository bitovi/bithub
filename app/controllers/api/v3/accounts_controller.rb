class Api::V3::AccountsController < Api::V3::BaseController
  before_action :set_account, only: %i(current)

  def current
    authorize!(:read, @account)
    render :show
  end

  private
  def set_account
    @account = current_account
  end
end
