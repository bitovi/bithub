class Api::Auth::AccountRegistrationsController < Devise::RegistrationsController

  protected

  def after_sign_up_path_for(resource)
    # hotfix: user and account cannot be logged in simultaneously
    sign_out current_user if current_user

    subdomain = resource.brand.name
    "http://#{subdomain}.#{request.domain}/admin"
  end

  def after_inactive_sign_up_path_for(resource)
    '/admin'
  end
end
