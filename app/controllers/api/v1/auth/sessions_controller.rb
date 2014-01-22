class Api::V1::Auth::SessionsController < Api::V1::BaseController

  def index
  end
  
  def new
  end
  
  def destroy
    sign_out
    redirect_to root_url
  end

end
