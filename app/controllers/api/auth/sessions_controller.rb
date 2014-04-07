class Api::Auth::SessionsController < Api::V1::BaseController
  before_filter :authenticate_user!
  respond_to :json

  def current
    @user = UserDecorator.decorate(current_user)
    render 'api/auth/session'
  end

  def destroy
    sign_out
    render :json => "{}"
  end

end
