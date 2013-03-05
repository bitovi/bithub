class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def twitter
    @identity = Identity.find_with_omniauth(request.env['omniauth.auth'])

    if @identity && @identity.persisted?
      sign_in_and_redirect(@identity.user, :event => :authentication) #this will throw if @user is not activated
      set_flash_message(:notice, :success, :kind => "Twitter") if is_navigational_format?
    else
      session["devise.facebook_data"] = request.env["omniauth.auth"]
      redirect_to new_user_registration_url
    end
  end

  def github
    @user = User.find_or_create(request.env["omniauth.auth"], current_user)

    if @user.persisted?
      sign_in_and_redirect @user, :event => :authentication #this will throw if @user is not activated
      set_flash_message(:notice, :success, :kind => "GitHub") if is_navigational_format?
    else
      session["devise.facebook_data"] = request.env["omniauth.auth"]
      redirect_to new_user_registration_url
    end
  end

end
