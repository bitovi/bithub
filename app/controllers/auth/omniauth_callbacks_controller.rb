class Auth::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  # force autoload
  Identities::Builders::Github
  Identities::Builders::Twitter
  Identities::Builders::Tumblr
  Identities::Builders::Instagram
  Identities::Builders::Facebook
  Identities::Builders::Foursquare
  Identities::Builders::Meetup
  Identities::Builders::Disqus
  Identities::Builders::Stackexchange

  # rescue_from Exception, :with => :show_auth_error
  # rescue_from RuntimeError, :with => :show_auth_error

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

  def show_auth_error
    render :template => 'oauth/auth_error.html.erb'
  end

  def passthru
    render :file => "#{Rails.root}/public/404.html", :status => 404, :layout => false
  end

  private

  def oauthorize(provider)
    raise 'Unknown tenant' unless brand = Brand.find_by_tenant_name(session['tenant_name'])
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
      # TODO return some reasonable error
      render :json => { message: 'error'}, :status => 406
    end
  end

  def oauth_data
    env["omniauth.auth"]
  end

end
