class Api::V2::AccountsController < Api::V2::BaseController
  #before_filter :authenticate_user!, except: [:index, :show]
  respond_to :json

  def index
    @accounts = Account.all

    render :index
  end

  def show
    @account = Account.find(params[:id])

    render :show
  end

end
