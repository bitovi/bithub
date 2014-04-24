class ApplicationController < ActionController::Base
  before_filter :redirect_to_subdomain

  def redirect_to_subdomain

    key = 'some really long key that we will use for this'
    crypt = ActiveSupport::MessageEncryptor.new(key)

    if params[:acc].present?
      account = Account.find(crypt.decrypt_and_verify(params[:acc]).to_i)
      subdomain = account.brand.name
      if subdomain == request.host.split('.').first
        sign_in(:account, account)
        redirect_to "/admin"
      end
    end

  end
end
