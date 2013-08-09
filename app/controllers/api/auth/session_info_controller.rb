class Api::Auth::SessionInfoController < Api::ApiController
  before_filter :authenticate_user!
  respond_to :json

  def current_session
    @user = UserDecorator.decorate(current_user)
    render 'api/users/session'
  end
end
