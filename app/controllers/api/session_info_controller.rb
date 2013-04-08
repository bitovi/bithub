class Api::SessionInfoController < ApplicationController
  respond_to :json

  def current_session
    if user_signed_in?
      @user = UserDecorator.decorate(current_user)
      render 'api/users/show'
    else
      #FIXME replace custom message with locale message
      render :json => { message: 'Unauthenticated' }, :status => 401
    end
  end
end
