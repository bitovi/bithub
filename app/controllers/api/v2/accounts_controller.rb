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

  def create
    account = Account.new(account_params)
    if account.save
      @account = AccountDecorator.decorate account
      render :show
    else
      render :json => msg_hash(account, 'create'), :status => 406
    end
  end

  def update
    account = Account.find(params[:id])
    if account.update_attributes(account_params)
      @account = AccountDecorator.decorate account
      render :show
    else
      render :json => msg_hash(account, 'update'), :status => 406
    end
  end

  def update_password
    account = Account.find(params[:id])
    password_params = params.require(:account).permit(:password, :password_confirmation, :current_password)

    if account.update_with_password(password_params)
      @account = AccountDecorator.decorate account
      render :show
    else
      render :json => msg_hash(account, 'update'), :status => 406
    end
  end

  private

  def account_params
    params.require(:account).permit(:email, :name, :props)
  end

end
