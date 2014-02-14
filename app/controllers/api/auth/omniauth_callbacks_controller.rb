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

  def link_identities
    @identity = Identity.find_or_create_with_provider_and_uid(oauth_data['provider'], oauth_data['uid'], oauth_data)
    AccountLinker.new(current_user, @identity).determine_state.link
  end

  private

  def oauthorize(kind)
    @sites = HashWithIndifferentAccess.new({
      github: 'GitHub',
      twitter: 'Twitter',
      meetup: 'Meetup'
    })

    @identity = Identity.find_or_init_with_provider_and_uid(kind, oauth_data['uid'], oauth_data)
    @manager = Accounts::AccountManager.new(kind, @identity, current_user)

    if @manager.linking_or_merging?
      Rails.logger.info "OVOJEZAGREP -> MERGAM" 
      session["devise.#{kind.downcase}_data"] = oauth_data
      session["current_oauth_data"] = oauth_data
      render :template => "oauth/account_linker.html.erb", :layout => false

    elsif @manager.only_logging_in?
      Rails.logger.info "OVOJEZAGREP -> LOGIRAM SAMO" 
      if (user = @manager.procure)
        session["devise.#{kind.downcase}_data"] = oauth_data
        sign_in user, :event => :authentication
        render :template => 'special/close_oauth_popup.html'
      else
        render :json => { message: 'error' }, :status => 500
      end
    end
  end

  def oauth_data
    env["omniauth.auth"]
  end
end
