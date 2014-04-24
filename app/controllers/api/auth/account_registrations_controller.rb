class Api::Auth::AccountRegistrationsController < Devise::RegistrationsController

  protected

  def after_sign_up_path_for(resource)
    subdomain = resource.brand.name
    key = 'some really long key that we will use for this'
    crypt = ActiveSupport::MessageEncryptor.new(key)

    "http://#{subdomain}.#{request.host}/login?acc=#{crypt.encrypt_and_sign(resource.id)}"
  end

  def after_inactive_sign_up_path_for(resource)
    '/admin'
  end
end
