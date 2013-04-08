class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def github
    oauthorize "github"
  end

  def twitter
    oauthorize "twitter"
  end

  def passthru
    render :file => "#{Rails.root}/public/404.html", :status => 404, :layout => false
  end

  private

  def oauthorize(kind)
    @user = find_or_create_with_ouath(kind, env["omniauth.auth"], current_user)
    if @user
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => kind
      session["devise.#{kind.downcase}_data"] = env["omniauth.auth"]
      sign_in @user, :event => :authentication
      render :template => 'special/close_oauth_popup.html'
    else
      #FIXME respond with error from a locale file
      render :json => { message: 'error' }, :status => 500
    end
  end

  def find_or_create_with_ouath(provider, oauth_data, resource=nil)
    user, email, name, uid, auth_attr = nil, nil, nil, {}

    case provider
    when "github"
      email = oauth_data['info']['email']
      name = oauth_data['info']['name']
    when "twitter"
      name = oauth_data['info']['name']
    else
      raise "Provider #{provider} not handled"
    end

    identity = Identity.find_with_omniauth(oauth_data)
    if user_signed_in? && resource
      resource.update_blank_oauth_attrs({name: name, email: email})
      if identity
        identity.update_source_data_if_blank(oauth_data['info'])
        resource.identities << identity if identity.user.blank?
        resource.save! if resource.changed?
      elsif !identity
        resource.identities.create(uid: oauth_data['uid'], provider: oauth_data['provider'], source_data: oauth_data['info'])
      end
      user = resource
    else
      identity = Identity.new(uid: oauth_data['uid'], provider: oauth_data['provider'], source_data: oauth_data['info']) if !identity
      identity.user = User.new({name: name, email: email}) if !identity.user
      identity.save!
      user = identity.user
    end

    return user
  end
end
