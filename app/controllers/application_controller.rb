class ApplicationController < ActionController::Base
  before_filter :redirect_to_subdomain

  helper_method :crypter

  def redirect_to_subdomain
    if params[:acc].present?
      account = Account.find(crypter.decrypt_and_verify(params[:acc]).to_i)
      subdomain = account.brand.name
      if subdomain == request.host.split('.').first
        sign_in(:account, account)
        redirect_to "/admin"
      end
    end
  end

  def crypter
    key = 'some really long key that we will use for this'
    @__crypt ||= ActiveSupport::MessageEncryptor.new(key)
    @__crypt
  end
end
