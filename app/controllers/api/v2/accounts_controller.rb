class Api::V2::AccountsController < Api::V2::BaseController
  #before_filter :authenticate_user!, except: [:index, :show]
  respond_to :json

  def index
    @accounts = AccountDecorator.decorate_collection Account.all
    render :index
  end

  def show
    @account = AccountDecorator.decorate Account.find(params[:id])
    render :show
  end

end
