class Api::Auth::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  class AccountLinker
    def initialize(current_user, identity)
    end

    def not_merging?
      merging_state == :not_merge
    end

    def valid_merge?
      merging_state == :valid_merge
    end

    def merging_user
      User.where('name ILIKE ?', '%brian%').first
    end

    def offending_identities
      User.where('name ILIKE ?', '%brian%').first.identities
    end

    def merging_state
      :valid_merge
    end
  end


  def github
    oauthorize "github"
  end

  def twitter
    oauthorize "twitter"
  end

  def meetup
    oauthorize "meetup"
  end

  def link_identity
    # do the linking magic
    render :template => 'special/close_oauth_popup.html'
  end

  def passthru
    render :file => "#{Rails.root}/public/404.html", :status => 404, :layout => false
  end

  private

  def oauthorize(kind)
    @sites = HashWithIndifferentAccess.new({
      github: 'GitHub',
      twitter: 'Twitter',
      meetup: 'Meetup'
    })

    session["devise.#{kind.downcase}_data"] = env["omniauth.auth"]
    session["current_oauth_data"] = env["omniauth.auth"]

    @identity       = Identity.new_from_oauth(env['omniauth.auth'])
    @account_linker = AccountLinker.new(current_user, @identity)

    render :template => "oauth/account_linker.html.erb", :layout => false

    # begin
    #   if (@user = Accounts::AccountManager.new(kind, oauth_data, current_user).find_or_create_user
    #     flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => kind
    #     session["devise.#{kind.downcase}_data"] = oauth_data
    #     sign_in @user, :event => :authentication
    #     render :template => 'special/close_oauth_popup.html'
    #   else
    #     render :json => { message: 'error' }, :status => 500
    #   end
    # rescue User::OtherUserAlreadyLinked => e
    #   render :template => 'special/identity_linking_error.html', :status => 406
    # end
  end

  def oauth_data
    env["omniauth.auth"]
  end
end
