class ApplicationController < ActionController::Base
  # before_filter :redirect_to_subdomain

  # def redirect_to_subdomain

  #   key = 'some really long key that we will use for this'
  #   crypt = ActiveSupport::MessageEncryptor.new(key)

  #   if current_account
  #     subdomain = current_account.brand.name

  #     if request.host.split('.').first != subdomain
  #       crypt = ActiveSupport::MessageEncryptor.new(key)
  #       redirect_to "http://#{subdomain}.#{request.host}/login?acc=#{crypt.encrypt_and_sign(current_account.id)}"
  #     end

  #   elsif params[:acc].present?
  #     account = Account.find(crypt.decrypt_and_verify(params[:acc]).to_i)
  #     subdomain = account.brand.name
  #     if subdomain == request.host.split('.').first
  #       sign_in(:account, account)
  #       redirect_to "/admin"
  #     end
  #   end

  # end
end
