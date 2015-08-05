class Api::V3::AccountsController < Api::V3::BaseController
  before_action :set_account, only: %i(current)

  def index
    @accounts = Account.all
  end

  def show
    @account = Account.find(params[:id])
    render @account
  end

  def current
    render @account
  end

  def update
    @account = params[:id] ? Account.find(params[:id]) : current_account
    if @account.update_attributes(update_params)
      render @account
    else
      render json: { msg: "Failed to update account." }, status: 500
    end
  end

  private
  def update_params
    params.require(:account).permit(:name)
  end
  
  def set_account
    @account = current_account
  end
end
