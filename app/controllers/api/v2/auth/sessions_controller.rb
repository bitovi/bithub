class Api::V2::Auth::SessionsController < Api::V2::BaseController
  before_filter :authenticate_user!
  respond_to :json

  def current
    @user = UserDecorator.decorate(current_user)
    render 'api/v2/auth/session'
  end

  def destroy
    sign_out
    render :json => {}
    #redirect_to root_url
  end

end
