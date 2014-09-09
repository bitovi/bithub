class ApplicationController < ActionController::Base

  helper_method :crypter

  def crypter
    key = 'some really long key that we will use for this'
    @__crypt ||= ActiveSupport::MessageEncryptor.new(key)
    @__crypt
  end
end
