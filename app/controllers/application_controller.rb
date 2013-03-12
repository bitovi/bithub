class ApplicationController < ActionController::Base
  protect_from_forgery

  def query
    q = request.env['muster.query']
    Rails.logger.info "==== QUERY ====" 
    Rails.logger.info q 
    render :text => q
  end
end
