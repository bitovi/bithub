class ApplicationController < ActionController::Base
  # protect_from_forgery
  
  def home
    render :text => "BitHub", :layout => true
  end
end
