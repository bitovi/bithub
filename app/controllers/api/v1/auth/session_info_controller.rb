class Api::V1::Auth::SessionInfoController < Api::V1::BaseController
  before_filter :authenticate_user!
  respond_to :json

  def current_session
    @user = UserDecorator.decorate(current_user)
    render 'api/users/session'
  end
end
