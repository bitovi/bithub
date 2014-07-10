class Api::Auth::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  # rescue_from Exception, :with => :show_auth_error
  # rescue_from RuntimeError, :with => :show_auth_error

  def github
    oauthorize "github"
  end

  def github_brand
    oauthorize_brand "github"
  end

  def twitter
    oauthorize "twitter"
  end

  def twitter_brand
    oauthorize_brand "twitter"
  end

  def meetup
    oauthorize "meetup"
  end

  def meetup_brand
    oauthorize_brand "meetup"
  end

  def stackexchange
    oauthorize "stackexchange"
  end

  def stackexchange_brand
    oauthorize_brand "stackexchange"
  end

  def facebook
    oauthorize "facebook"
  end

  def facebook_brand
    oauthorize_brand "facebook"
  end

  def disqus
    oauthorize "disqus"
  end

  def disqus_brand
    oauthorize_brand "disqus"
  end

  def foursquare
    oauthorize "foursquare"
  end

  def foursquare_brand
    oauthorize_brand "foursquare"
  end

  ###

  def show_auth_error
    render :template => 'oauth/auth_error.html.erb'
  end

  def passthru
    render :file => "#{Rails.root}/public/404.html", :status => 404, :layout => false
  end

  def link_identities
    @identity = Identity.find_or_create_with_oauth_data(oauth_data)
    Accounts::AccountLinker.new(current_user, @identity).determine_state.link
    render :template => 'special/close_oauth_popup.html'
  end

  private

  def oauthorize(kind)
    @sites = HashWithIndifferentAccess.new({
      github: 'GitHub',
      twitter: 'Twitter',
      meetup: 'Meetup',
      stackexchange: 'StackExchange',
      facebook: 'Facebook',
      disqus: 'Disqus',
      foursquare: 'Foursquare'
    })

    # hotfix: user and account cannot be logged in simultaneously
    sign_out current_account if current_account

    @identity = Identity.find_or_init_with_oauth_data(oauth_data)
    @manager = Accounts::AccountManager.new(kind, @identity, current_user)
    @manager.linker.determine_state

    if @manager.linking_or_merging?
      session["devise.#{kind.downcase}_data"] = oauth_data
      session["current_oauth_data"] = oauth_data
      render :template => "oauth/account_linker.html.erb", :layout => false

    elsif @manager.only_logging_in?
      if (user = @manager.procure)
        session["devise.#{kind.downcase}_data"] = oauth_data
        sign_in user, :event => :authentication
        render :template => 'special/close_oauth_popup.html'
      else
        render :json => { message: 'error' }, :status => 500
      end
    end
  end

  def oauthorize_brand(kind)
    account = Account.find(current_account[:id])
    brand = account.brand
    uid = oauth_data[:uid].to_s

    # Build identity source_data
    source_data = Identities::Builders.const_get(kind.camel_case).new({oauth: oauth_data}).build

    # Find or update brand
    if (identity = brand.identities.where(provider: kind, uid: uid).first)
      identity.source_data = source_data
    else
      identity = brand.identities.build({provider: kind, uid: oauth_data[:uid], source_data: source_data})
    end

    if identity.save
      render :template => 'special/close_oauth_popup.html'
    else
      # return some reasonable error
      render :json => { message: 'error'}, :status => 406
    end
  end

  def oauth_data
    env["omniauth.auth"] || session["current_oauth_data"]
  end
end
