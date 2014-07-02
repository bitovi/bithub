class Api::Auth::AccountSessionsController < Devise::SessionsController

  protected

  def after_sign_in_path_for(resource)
    if request.subdomain.empty? && !current_account.has_role?(:admin)
      "http://#{current_account.brand.name}.#{request.host}/admin"
    else
      '/admin'
    end
  end

  def after_sign_out_path_for(resource_or_scope)
    "http://#{request.domain}/login"
  end

end
