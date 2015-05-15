class Auth::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def github
    oauthorize "github"
  end

  def twitter
    oauthorize "twitter"
  end

  def meetup
    oauthorize "meetup"
  end

  def stackexchange
    oauthorize "stackexchange"
  end

  def facebook
    oauthorize "facebook"
  end

  def disqus
    oauthorize "disqus"
  end

  def foursquare
    oauthorize "foursquare"
  end

  def instagram
    oauthorize "instagram"
  end

  def tumblr
    oauthorize "tumblr"
  end

  def google_oauth2
    oauthorize "google_oauth2"
  end

  def show_auth_error
    render :template => 'oauth/auth_error.html.erb'
  end

  def passthru
    render :file => "#{Rails.root}/public/404.html", :status => 404, :layout => false
  end

  private

  def oauthorize(provider)
    raise 'Unknown tenant' unless current_brand
    uid = oauth_data[:uid].to_s

    if identity_exists?(provider, uid)
      @identity.source_data = oauth_data
    else
      @identity = BrandIdentity.new({
        brand: current_brand,
        provider: provider,
        uid: oauth_data[:uid],
        source_data: oauth_data
      })
    end
    @identity.extracted_data = @identity.builder.extracted_data

    if @identity.save
      render :template => 'special/close_oauth_popup.html'
    else
      render :json => { message: 'error'}, :status => 406
    end
  end

  def oauth_data
    env["omniauth.auth"]
  end

  def identity_exists?(provider, uid)
    @identity = current_brand.identities.where(provider: provider, uid: uid).first
  end

  def current_brand
    @current_brand ||= Brand.find_by_tenant_name(session['tenant_name'])
  end
end
