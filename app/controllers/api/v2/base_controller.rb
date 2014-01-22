class Api::V2::BaseController < ActionController::Base

  def home
    render :text => "Bithub API v2"
  end
end
