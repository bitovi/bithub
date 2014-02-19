class Api::Auth::IdentitiesController < Api::V1::BaseController

  rescue_from Exception, :with => :show_auth_error
  rescue_from RuntimeError, :with => :show_auth_error

  def link
    @identity = Identity.find_or_create_with_oauth_data(oauth_data)
    Accounts::AccountLinker.new(current_user, @identity).determine_state.link
    render :template => 'special/close_oauth_popup.html'
  end

  def unlink
    @identity = Identity.find_by_uid(params[:uid])
    Accounts::AccountLinker.new(current_user, @identity).unlink
    render :json => @identity.to_json
  end

  def oauth_data
    env["omniauth.auth"] || session["current_oauth_data"]
  end
  
  def show_auth_error
    render :template => 'oauth/auth_error.html.erb'
  end
end
