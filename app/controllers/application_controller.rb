class ApplicationController < ActionController::Base
  before_filter :authenticate_user!, :only => ['create', 'update']

  def home
    render :text => "Hello!"
  end

  def ensure_authenticated
    render :json => { msg: 'FoF' } if !user_signed_in?
  end
end
