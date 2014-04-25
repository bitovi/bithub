class Api::Auth::SignInOauthController < ApplicationController
  def login_and_redirect_to_oauth
    if params[:oauth_acc].present?
      sign_in(:account, Account.find(crypter.decrypt_and_verify(params[:oauth_acc])))
      redirect_to "/api/auth/#{params[:brand]}_brand"
    end
  end
end