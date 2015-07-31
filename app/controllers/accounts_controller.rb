class AccountsController < ApplicationController

  before_filter :authenticate_account!
  layout 'backend_admin'

  def index
    authorize!(:read, Account)
    @accounts = Account.all

    render :index
  end
end
