class Api::Auth::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def github
    oauthorize "github"
  end

  def twitter
    oauthorize "twitter"
  end
  
  def meetup
    oauthorize "meetup"
  end

  def passthru
    render :file => "#{Rails.root}/public/404.html", :status => 404, :layout => false
  end

  private

  def oauthorize(kind)
    begin
      if (@user = AccountManager.new(current_user).find_or_create_user(kind, env["omniauth.auth"]))
        flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => kind
        session["devise.#{kind.downcase}_data"] = env["omniauth.auth"]
        sign_in @user, :event => :authentication
        render :template => 'special/close_oauth_popup.html'
      else
        render :json => { message: 'error' }, :status => 500
      end
    rescue User::OtherUserAlreadyLinked => e
      render :template => 'special/identity_linking_error.html', :status => 406
    else
      # other exception
    ensure
      # always executed
    end
  end
end
