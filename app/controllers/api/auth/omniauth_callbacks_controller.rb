class Api::Auth::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  # rescue_from Exception, :with => :show_auth_error
  # rescue_from RuntimeError, :with => :show_auth_error

  PROVIDERS = %w(github, twitter, meetup, stackexchange, facebook, disqus, foursquare, instagram, tumbler)

  PROVIDERS.each do |provider|
    define_method(provider) { oauthorize(provider) }
  end

  def show_auth_error
    render :template => 'oauth/auth_error.html.erb'
  end

  def passthru
    render :file => "#{Rails.root}/public/404.html", :status => 404, :layout => false
  end

  private

  def oauthorize(provider)
    account = Account.find(current_account[:id])
    brand = account.brand
    uid = oauth_data[:uid].to_s

    # Build identity source_data
    source_data = Identities::Builders.const_get(provider.camel_case).new({oauth: oauth_data}).build

    # Find or update brand
    if identity = brand.identities.where(provider: provider, uid: uid).first
      identity.source_data = source_data
    else
      identity = brand.identities.build({provider: provider, uid: oauth_data[:uid], source_data: source_data})
    end

    if identity.save
      render :template => 'special/close_oauth_popup.html'
    else
      # return some reasonable error
      render :json => { message: 'error'}, :status => 406
    end
  end

  def oauth_data
    env["omniauth.auth"] # || session["current_oauth_data"]
  end

end
