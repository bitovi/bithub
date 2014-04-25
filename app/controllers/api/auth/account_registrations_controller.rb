class Api::Auth::AccountRegistrationsController < Devise::RegistrationsController

  protected

  def after_sign_up_path_for(resource)
    subdomain = resource.brand.name

    "http://#{subdomain}.#{request.host}/login?acc=#{crypter.encrypt_and_sign(resource.id)}"
  end

  def after_inactive_sign_up_path_for(resource)
    '/admin'
  end
end
