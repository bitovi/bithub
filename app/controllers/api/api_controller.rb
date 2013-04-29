class Api::ApiController < ActionController::Base
  before_filter :authenticate_user!, :only => ['create', 'update']

  def home
    render :text => "Bithub API v1"
  end
end
