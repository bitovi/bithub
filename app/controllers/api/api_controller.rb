class Api::ApiController < ActionController::Base
  before_filter :authenticate_user!, :only => ['create', 'update', 'destroy']

  def home
    render :text => "Bithub API v1"
  end

  def show_404(exception)
    render json: exception, status: 404
  end

  def show_406
    render json: exception, status: 406
  end
end
