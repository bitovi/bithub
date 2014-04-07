class Api::V2::BaseController < ActionController::Base
  respond_to :json

  include Api::V2::BaseHelpers

  def home
    render :text => "Bithub API v2"
  end
end
