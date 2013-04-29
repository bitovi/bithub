class Api::SessionInfoController < Api::ApiController
  respond_to :json
  before_filter :authenticate_user!


  def current_session
    @user = UserDecorator.decorate(current_user)
    render 'api/users/show'
  end
end
