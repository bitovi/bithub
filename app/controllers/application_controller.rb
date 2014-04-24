class ApplicationController < ActionController::Base
  before_filter :redirect_to_subdomain

  def redirect_to_subdomain

    if current_account
      subdomain = current_account.brand.name

      if request.host.split('.').first != subdomain
        redirect_to "http://#{subdomain}.#{request.host}/login?acc=#{current_account.id}"
      end

    elsif params[:acc].present?
      sign_in(:account, Account.find(params[:acc].to_i))
      redirect_to "/admin"
    end

  end
end
